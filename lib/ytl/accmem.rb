module YTL
  class Memory
  end
  TheMemory = Memory.new
end

module YTLJit
  module VM
    module Node
      
      module AccMemUtil
        include SendUtil
        include X86
        include X64

        def collect_candidate_type_regident(context, slf)
          cursig = context.to_signature
          @arguments[3].decide_type_once(cursig)
          if slf.ruby_type <= YTL::Memory then
            kind = @arguments[4]
            kvalue = kind.get_constant_value

            if kvalue then
              kvalue =kvalue[0]
              
              case kvalue
              when :char, :word, :dword, :machine_word
                fixtype = RubyType::BaseType.from_ruby_class(Fixnum)
                add_type(cursig, fixtype)
                
              when :float 
                floattype = RubyType::BaseType.from_ruby_class(Float)
                add_type(cursig, floattype)
                
              when AsmType::StructMember
                if kvalue.type.is_a?(AsmType::Scalar) then
                  if kvalue.type.kind == :int then
                    ttype = RubyType::BaseType.from_ruby_class(Fixnum)
                    add_type(cursig, ttype)
                  elsif kvalue.type.kind == :float then
                    ttype = RubyType::BaseType.from_ruby_class(Float)
                    add_type(cursig, ttype)
                  else
                    raise "Unkown type #{kvalue.type} #{kvalue.type.kind}"
                  end
                else
                  raise "Unkown type #{kvalue}"
                end

              when AsmType::Scalar
                if kvalue.kind == :int then
                  ttype = RubyType::BaseType.from_ruby_class(Fixnum)
                  add_type(cursig, ttype)

                else
                  raise "Unkown type"
                end

              else
                raise "Unkown type #{kvalue}"

              end
              
            else
              fixtype = RubyType::BaseType.from_ruby_class(Fixnum)
              add_type(cursig, fixtype)
            end

            context

          elsif slf.ruby_type <= AsmType::Pointer or
              slf.ruby_type <= AsmType::Array then
            tt = AsmType::PointedData
            pointedtype = RubyType::BaseType.from_ruby_class(tt)
            add_type(cursig, pointedtype)
            context

          elsif slf.ruby_type <= AsmType::Struct or
              slf.ruby_type <= AsmType::Union or 
              slf.ruby_type <= AsmType::StructMember then
            tt = AsmType::StructMember
            stmemtype = RubyType::BaseType.from_ruby_class(tt)
            add_type(cursig, stmemtype)
            context

          else
            super
          end
        end

        def gen_read_mem(context, type)
          size = type.size
          asm = context.assembler
          case type.kind
          when :int
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

          when :float
            case size
            when 8
              asm.with_retry do
                if context.ret_reg != RAX then
                  asm.mov(RAX, context.ret_reg)
                end
                asm.movsd(RETFR, INDIRECT_RAX)
              end
              context.ret_reg = RETFR
              
            when 4
              asm.with_retry do
                if context.ret_reg != EAX then
                  asm.mov(EAX, context.ret_reg)
                end
                asm.movss(RETFR, INDIRECT_EAX)
              end
              context.ret_reg = RETFR
              
            else
              raise "Unkown Scalar size #{kvalue}"
            end
          end

          context
        end

        def gen_write_mem(context, type)
          size = type.size
          asm = context.assembler
          case type.kind
          when :int
            case size
            when 8
              asm.with_retry do
                if context.ret_reg != RAX then
                  asm.mov(RAX, context.ret_reg)
                end
                asm.mov(INDIRECT_TMPR2, RAX)
              end
              context.ret_reg = RAX
              
            when 4
              asm.with_retry do
                if context.ret_reg != EAX then
                  asm.mov(EAX, context.ret_reg)
                end
                asm.mov(INDIRECT_TMPR2, EAX)
              end
              context.ret_reg = EAX
              
            when 2
              asm.with_retry do
                asm.mov(AL, context.ret_reg)
                asm.mov(INDIRECT_TMPR2, AL)
              end
              context.ret_reg = EAX
              
            else
              raise "Unkown Scalar size #{kvalue}"
            end

          when :float
            case size
            when 8
              asm.with_retry do
                if context.ret_reg != RETFR then
                  asm.mov(RETFR, context.ret_reg)
                end
                asm.movsd(INDIRECT_TMPR2, RETFR)
              end
              context.ret_reg = RETFR
              
            when 4
              asm.with_retry do
                if context.ret_reg != RETFR then
                  asm.mov(RETFR, context.ret_reg)
                end
                asm.movss(INDIRECT_TMPR2, RETFR)
              end
              context.ret_reg = RETFR
              
            else
              raise "Unkown Scalar size #{kvalue}"
            end
          end

          context
        end

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
      end

      class SendElementRefMemoryNode<SendElementRefNode
        include AccMemUtil
        include SendUtil
        include X86
        include X64

        add_special_send_node :[]

        def collect_candidate_type_regident(context, slf)
          super
        end

        def compile_ref_scalar(context, typeobj)
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
              context = gen_read_mem(context, kvalue)
              
            when AsmType::StructMember
              typeobj = kvalue.type
              case typeobj
              when AsmType::Scalar
                asm.with_retry do
                  asm.add(context.ret_reg, kvalue.offset)
                end
                context = gen_read_mem(context, typeobj)
                
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

      class SendElementAssignMemoryNode<SendElementAssignNode
        include AccMemUtil
        include SendUtil
        include X86
        include X64

        add_special_send_node :[]=

        def collect_candidate_type_regident(context, slf)
          # value to set
          if slf.ruby_type <= YTL::Memory then
            context = @arguments[5].collect_candidate_type(context)
          end
          super
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
            context.start_using_reg(TMPR2)
            asm.with_retry do
              asm.mov(TMPR2, context.ret_reg)
            end
            context = @arguments[5].compile(context)

            case kvalue
            when :machine_word
              asm.with_retry do
                if context.ret_reg != RETR then
                  asm.mov(RETR, context.ret_reg)
                end
                asm.mov(INDIRECT_TMPR2, RETR)
              end
              context.ret_reg = RETR
              
            when :float
              asm.with_retry do
                if context.ret_reg != RETFR then
                  asm.mov(RETFR, context.ret_reg)
                end
                asm.mov(INDIRECT_TMPR, RETFR)
              end
              context.ret_reg = RETFR
              
            when AsmType::Scalar
              context = gen_write_mem(context, kvalue)
              
            when AsmType::StructMember
              typeobj = kvalue.type
              case typeobj
              when AsmType::Scalar
                asm.with_retry do
                  asm.add(TMPR2, kvalue.offset)
                end
                context = gen_write_mem(context, typeobj)
                
              else
                raise "Unkown Struct Member type #{kvalue}"
              end
            end
            
            context.ret_node = self
            context.end_using_reg(TMPR2)

            @body.compile(context)
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
          slfcls = @arguments[2].get_constant_value
          tt = RubyType::BaseType.from_ruby_class(slfcls[0])
          if tt.ruby_type == Runtime::Arena then
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
