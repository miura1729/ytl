module YTL
  class Memory
  end
  TheMemory = Memory.new
end

module YTLJit
  module VM
    module Node

      class SendElementRefMemoryNode<SendElementRefNode
        include SendUtil
        include X86
        include X64

        add_special_send_node :[]

        def fill_result_cache(context)
          slf = @arguments[2]
          slfval = @arguments[2].get_constant_value
          if slfval then
            slfval =slfval[0]

            idxval = @arguments[3].get_constant_value
            if idxval then
              idxval = idxval[0]
              @result_cache = slfval[idxval]
            end
          end

          context
        end

        def collect_candidate_type_regident(context, slf)
          if slf.ruby_type <= YTL::Memory then
            kind = @arguments[4]
            kvalue = kind.get_constant_value

            if kvalue then
              kvalue =kvalue[0]
              
              case kvalue
              when :char, :word, :dword, :machine_word
                fixtype = RubyType::BaseType.from_ruby_class(Fixnum)
                add_type(context.to_signature, fixtype)
                
              when :float 
                floattype = RubyType::BaseType.from_ruby_class(Float)
                add_type(context.to_signature, floattype)
                
              when AsmType::StructMember
                if kvalue.type.is_a?(AsmType::Scalar) then
                  if kvalue.type.kind == :int then
                    ttype = RubyType::BaseType.from_ruby_class(Fixnum)
                    add_type(context.to_signature, ttype)
                  else
                    raise "Unkown type #{kvalue.type} #{kvalue.type.kind}"
                  end
                else
                  raise "Unkown type #{kvalue}"
                end

              when AsmType::Scalar
                if kvalue.kind == :int then
                  ttype = RubyType::BaseType.from_ruby_class(Fixnum)
                  add_type(context.to_signature, ttype)

                else
                  raise "Unkown type"
                end

              else
                raise "Unkown type #{kvalue}"

              end
              
            else
              fixtype = RubyType::BaseType.from_ruby_class(Fixnum)
              add_type(context.to_signature, fixtype)
            end

            context

          elsif slf.ruby_type <= AsmType::Pointer or
              slf.ruby_type <= AsmType::Array then
            tt = AsmType::PointedData
            pointedtype = RubyType::BaseType.from_ruby_class(tt)
            add_type(context.to_signature, pointedtype)
            context

          elsif slf.ruby_type <= AsmType::Struct or
              slf.ruby_type <= AsmType::Union or 
              slf.ruby_type <= AsmType::StructMember then
            tt = AsmType::StructMember
            stmemtype = RubyType::BaseType.from_ruby_class(tt)
            add_type(context.to_signature, stmemtype)
            context

          else
            super
          end
        end

        def compile_ref_scalar(context, typeobj)
          context
        end

        def gen_read_mem(context, size)
          asm = context.assembler
          case size
          when 8
            asm.with_retry do
              if context.ret_reg != RAX then
                asm.mov(RAX, context.ret_reg)
              end
              asm.mov(RAX, INDIRECT_RAX)
            end
            context.ret_reg = RAX
            
          when 4
            asm.with_retry do
              if context.ret_reg != EAX then
                asm.mov(EAX, context.ret_reg)
              end
              asm.mov(EAX, INDIRECT_EAX)
            end
            context.ret_reg = EAX
            
          when 2
            asm.with_retry do
              asm.mov(AL, context.ret_reg)
              asm.mov(AL, INDIRECT_AL)
            end
            context.ret_reg = EAX
            
          else
            raise "Unkown Scalar size #{kvalue}"
          end

          context
        end
        
        def compile(context)
          slf = @arguments[2]
          slf.decide_type_once(context.to_signature)
          if slf.type.ruby_type <= YTL::Memory then
            asm = context.assembler

            kind = @arguments[4]
            kvalue = nil
            case kind
            when LiteralNode
              kvalue = kind.value

            else
              context = kind.compile(context)
              if context.ret_reg.is_a?(OpVarImmidiateAddress) then
                objid = (context.ret_reg.value >> 1)
                kvalue = ObjectSpace._id2ref(objid)
              end
            end

            context = @arguments[3].compile(context)

            case kvalue
            when :machine_word
              asm.with_retry do
                if context.ret_reg != TMPR then
                  asm.mov(TMPR, context.ret_reg)
                end
                asm.mov(RETR, INDIRECT_TMPR)
              end
              context.ret_reg = RETR
              
            when :float
              asm.with_retry do
                if context.ret_reg != TMPR then
                  asm.mov(TMPR, context.ret_reg)
                end
                asm.mov(RETFR, INDIRECT_TMPR)
              end
              context.ret_reg = RETFR
              
            when AsmType::Scalar
              context = gen_read_mem(context, kvalue.size)
              
            when AsmType::StructMember
              typeobj = kvalue.type
              case typeobj
              when AsmType::Scalar
                context = gen_read_mem(context, typeobj.size)
                
              else
                raise "Unkown Struct Member type #{kvalue}"
              end
            end
            
            context.ret_node = self
            return context
            
          elsif slf.type.ruby_type <= AsmType::TypeCommon then
            context = @arguments[2].compile(context)
            obj = slf.get_constant_value
            
            if obj == nil and 
                context.ret_reg.is_a?(OpVarImmidiateAddress) then
              objid = (context.ret_reg.value >> 1)
              obj = ObjectSpace._id2ref(objid)
            else
              obj = obj[0]
            end
            
            if obj then
              index = @arguments[3].get_constant_value

              if index then
                index = index[0]
                val = obj[index]
                add = lambda { val.address }
                context.ret_reg = OpVarImmidiateAddress.new(add)
                context.ret_node = self
                
                return context
              end
            end
            
            super
          else
            super
          end
        end
      end

      class SendNewArenaNode<SendNewNode
        add_special_send_node :new

        def traverse_childlen
          @arguments.each do |arg|
            yield arg
          end
          yield @func
          yield @body
        end

        def collect_candidate_type_regident(context, slf)
          if Runtime::Arena.is_a?(slf.ruby_type) then
            slfcls = @arguments[2].get_constant_value
            tt = RubyType::BaseType.from_ruby_class(slfcls[0])
            add_type(context.to_signature, tt)
              
            if @initmethod.is_a?(SendInitializeNode) then
              # Get alloc method call node
              @initmethod = @initmethod.arguments[2]
            end

            return context
          end

          return super
        end
      end

      class SendAddressNode<SendNode
        include InternalRubyType
        add_special_send_node :address

        def collect_candidate_type_regident(context, slf)
          if slf.ruby_type == Runtime::Arena then
            tt = RubyType::BaseType.from_ruby_class(Fixnum)
            add_type(context.to_signature, tt)

            return context
          end

          super
        end

        def compile(context)
          context = @arguments[2].compile(context)
          @arguments[2].decide_type_once(context.to_signature)
          rtype = @arguments[2].type
          rrtype = rtype.ruby_type
          if rrtype == Runtime::Arena then
            asm = context.assembler
            rsdata = TypedData.new(RData, context.ret_reg)
            asm.with_retry do
              dmy, arena = asm.mov(TMPR, rsdata[:data])
              asm.mov(TMPR, arena[0][:body])
            end
            context.ret_reg = TMPR
            context.ret_node = self
            context
          else
            super
          end
        end
      end

      class SendInstanceMemoryNode<SendNode
        add_special_send_node :instance

        def collect_candidate_type_regident(context, slf)
          if YTL::Memory.is_a?(slf.ruby_type) then
            slfcls = @arguments[2].get_constant_value
            if slfcls then
              tt = RubyType::BaseType.from_ruby_class(slfcls[0])
              add_type(context.to_signature, tt)
            end

            return context
          end

          super
        end

        def compile(context)
          @arguments[2].decide_type_once(context.to_signature)
          rtype = @arguments[2].type
          rrtype = rtype.ruby_type
          if YTL::Memory.is_a?(rrtype) then
            objadd = lambda {
              YTL::TheMemory.address
            }
            context.ret_reg = OpVarImmidiateAddress.new(objadd)
            context.ret_node = self
            context
          else
            super
          end
        end
      end
    end
  end
end
