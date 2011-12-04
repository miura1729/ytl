module YTLJit
  module VM
    module TypeCodeGen
      module YTLJitRuntimeThreadTypeBoxedCodeGen
        include TypeUtil
        def instance
          ni = self.dup
          ni.instance_eval { extend YTLJitRuntimeThreadTypeBoxedCodeGen }
          ni.init
          ni
        end

        def init
          @element_type = nil
        end

        attr_accessor :element_type

        def gen_copy(context)
          context
        end

        def have_element?
          true
        end

        def inspect
          "{#{@ruby_type} self=#{@element_type.inspect}}"
        end
      end
    end

    module Node
      class SimpleVectorRefNode<BaseNode
        def initialize(parent, offset, basereg)
          super(parent)
          @offset = offset
          @base_reg = basereg
        end

        def collect_candidate_type(context)
          context
        end

        def compile(context)
          asm = context.assembler
          siz = AsmType::MACHINE_WORD.size
          src = OpIndirect.new(@base_reg, @offset * siz)
          asm.with_retry do
            asm.mov(TMPR, src)
          end
          context.ret_reg = TMPR
          context.ret_node = self
          context
        end
      end
      
      class SendThreadPselfNode<SendNode
        add_special_send_node :pself
        def collect_candidate_type_regident(context, slf)
          cursig = context.to_signature
          slfcls = @arguments[2].decide_type_once(cursig)
          if slfcls.ruby_type == Runtime::Thread then
            add_type(cursig, slfcls.element_type[nil][0])
            context
          else
            super
          end
        end
      end

      class SendThreadCselfNode<SendThreadPselfNode
        add_special_send_node :cself
      end

      class SendThreadNewNode<SendNewArenaNode
        include NodeUtil
        include SendSingletonClassUtil
        add_special_send_node :new
        
        def initialize(parent, func, arguments, op_flag, seqno)
          super
          @yield_node = nil
          @block_cs = CodeSpace.new
          @block_args = []
          @frame_info = search_frame_info
          @arguments.each_with_index do |ele, idx|
            nnode = nil
            if idx != 1 then
              nnode = SimpleVectorRefNode.new(self, idx + 1, TMPR2)
            else
              nnode = @arguments[1]
            end
            @block_args.push nnode
          end
          func = DirectBlockNode.new(self, @arguments[1])
          @yield_node = SendNode.new(self, func, @block_args, 0, 0)
          @modified_instance_var = nil
          @curpare = [nil, []]
        end

        def collect_info(context)
          context.modified_instance_var[:@_prev_self] ||= []
          context.modified_instance_var[:@_prev_self].push @curpare
          @modified_instance_var = context.modified_instance_var
          @arguments.each do |arg|
            context = arg.collect_info(context)
          end
          context = @func.collect_info(context)
          @body.collect_info(context)
        end

        def collect_candidate_type_regident(context, slf)
          slfcls = @arguments[2].get_constant_value
          tt = RubyType::BaseType.from_ruby_class(slfcls[0])
          if tt.ruby_type == Runtime::Thread then
            cursig = context.to_signature
            slfnode = @frame_info.frame_layout[-1]
            blknode = @arguments[1]
            [@arguments[0], blknode, slfnode].zip(@block_args) do |bele, oele|
              same_type(oele, bele, cursig, cursig, context)
            end

            yargs = @block_args
            context = @yield_node.collect_candidate_type(context)
            ysignat = @yield_node.signature(context)
            context = blknode.collect_candidate_type(context, yargs, ysignat)

            tt = RubyType::BaseType.from_ruby_class(Runtime::Thread)
            add_type(context.to_signature, tt)
            joinsig = cursig.dup
            joinsig[1] = RubyType::BaseType.from_ruby_class(NilClass)
            joinsig[2] = tt
            add_element_node(tt, cursig, slfnode, nil, context)
            add_element_node(tt, ysignat, slfnode, nil, context)
            same_type(slfnode, slfnode, ysignat, cursig, context)
            add_element_node(tt, joinsig, slfnode, nil, context)
            same_type(slfnode, slfnode, joinsig, cursig, context)
            
            @curpare[0] = slfnode
            if !@curpare[1].include?(cursig) then
              @curpare[1].push cursig
            end

            return context
          end

          return super
        end

        def compile(context)
          rect = @arguments[2].decide_type_once(context.to_signature)
          rrtype = rect.ruby_type_raw
          if rrtype.is_a?(ClassClassWrapper) then
            rrtype = get_singleton_class_object(@arguments[2]).ruby_type
            if rrtype == Runtime::Thread then
              cursig = context.to_signature

              # Generate block invoker
              tcontext = context.dup
              tcontext.set_code_space(@block_cs)
              asm = tcontext.assembler
              asm.with_retry do
                asm.mov(TMPR, FUNC_ARG[0])
              end
              tcontext.start_using_reg(TMPR2)
              asm.with_retry do
                asm.mov(TMPR2, TMPR)
                asm.mov(THEPR, INDIRECT_TMPR2)
              end
              tcontext = @yield_node.compile(tcontext)
              tcontext.end_using_reg(TMPR2)
              addr = lambda {
                a = address_of('ytl_thread_exit')
                $symbol_table[a] = 'yth_thread_exit'
                a
              }
              thread_exit = OpVarMemAddress.new(addr)
              asm.with_retry do
                asm.push(tcontext.ret_reg)
                asm.call(thread_exit)
                # never reach here
              end

              # Compile to call ytl_thread_create
              addr = lambda {
                a = address_of('ytl_thread_create')
                $symbol_table[a] = 'yth_thread_create'
                a
              }
              thread_create = OpVarMemAddress.new(addr)

              addr = lambda {
                a = address_of('ytl_ivar_set_boxing')
                $symbol_table[a] = 'yth_ivar_set_boxing'
                a
              }
              ivar_set = OpVarMemAddress.new(addr)
              ivaroff = @modified_instance_var.keys.index(:@_prev_self)
              orgslf = OpIndirect.new(SPR, AsmType::MACHINE_WORD.size)

              asm = context.assembler
              context.start_using_reg(TMPR2)
              asm.with_retry do
                asm.mov(TMPR, @frame_info.offset_arg(2, BPR))
                asm.push(TMPR)
              end
              context.ret_reg = TMPR
              context = cursig[2].gen_copy(context)
              
              asm.with_retry do
                asm.push(context.ret_reg)

                #  write prev self to copyed self
                asm.mov(TMPR2, orgslf)
                asm.mov(FUNC_ARG[0], context.ret_reg)
                asm.mov(FUNC_ARG[1], ivaroff)
                asm.mov(FUNC_ARG[2], TMPR2)
                asm.call_with_arg(ivar_set, 3)

                asm.mov(TMPR, @frame_info.offset_arg(1, BPR))
                asm.push(TMPR)  # block addr
                asm.push(BPR)   # oldbp
                asm.push(THEPR)
                asm.mov(TMPR, SPR)
                asm.mov(FUNC_ARG[0], TMPR)
                asm.mov(TMPR, @block_cs.var_base_immidiate_address)
                asm.mov(FUNC_ARG[1], TMPR)
              end
              context = gen_call(context, thread_create, 2)
              asm.with_retry do
                asm.add(SPR, AsmType::MACHINE_WORD.size * 5)
              end

              context.end_using_reg(TMPR2)
              context.ret_reg = RETR
              context.ret_node = self

              return context
            else
              super
            end
          else
            super
          end
        end
      end
    end
  end
end
