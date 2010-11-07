module YTL
  class Memory
  end
  TheMemory = Memory.new
end

module YTLJit
  module VM
    module Node

      class SendElementRefMemory<SendElementRefNode
        include SendUtil

        add_special_send_node :[]

        def collect_candidate_type_regident(context, slf)
          if slf.ruby_type <= YTL::Memory then
            kind = @arguments[4]
            kvalue = nil

            case kind
            when LiteralNode
              kvalue = kind.value

            when SendElementRefNode
              kvalue = AsmType::Scalar

            else
              raise "Not support yet #{kind.class} "
            end
            
            case kvalue
            when :char, :word, :dword, :machine_word
              fixtype = RubyType::BaseType.from_ruby_class(Fixnum)
              add_type(context.to_signature, fixtype)
              
            when :float 
              floattype = RubyType::BaseType.from_ruby_class(Float)
              add_type(context.to_signature, floattype)

            when AsmType::StructMember, AsmType::Scalar
              ttype = RubyType::BaseType.from_ruby_class(kvalue.type)
              add_type(context.to_signature, ttype)
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
        
        def compile(context)
          slf = @arguments[2]
          slf.decide_type_once(context.to_signature)
          if slf.type.ruby_type <= YTL::Memory then
            kind = @arguments[4]
            context = @arguments[3].compile(context)
            asm = context.assembler
            kvalue = nil
            case kind
            when LiteralNode
              kvalue = kind.value

            else
              context = @arguments[4].compile(context)
              if context.ret_reg.is_a?(OpVarImmidiateAddress) then
                objid = (context.ret_reg.value >> 1)
                kvalue = ObjectSpace._id2ref(objid)
              end
            end

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
              case kvalue.size
              when 4
                asm.with_retry do
                  if context.ret_reg != TMPR then
                    asm.mov(TMPR, context.ret_reg)
                  end
                  asm.mov(RETR, INDIRECT_TMPR)
                end
                context.ret_reg = RETR
                
              else
                raise "Unkown Scalar size #{kvalue}"
              end
              
            when AsmType::StructMember
              typeobj = kvalue.type
              case typeobj
              when AsmType::Scalar
                case typeobj.size
                when 4
                  asm.with_retry do
                    if context.ret_reg != TMPR then
                      asm.mov(TMPR, context.ret_reg)
                    end
                    src = OpIndirect.new(TMPR, kvalue.offset)
                    asm.mov(RETR, src)
                  end
                  context.ret_reg = RETR
                  
                else
                  raise "Unkown Scalar size #{kvalue}"
                end
                
              else
                raise "Unkown Struct Member type #{kvalue}"
              end
            end
            
            context.ret_node = self
            return context
            
          elsif slf.type.ruby_type <= AsmType::TypeCommon then
            context = @arguments[2].compile(context)
            obj = nil
            case slf
            when LiteralNode
              obj = slf.value
              
            when ConstantRefNode
              node = slf.value_node
              case node
              when LiteralNode
                obj = node.value
              end
            end
            
            if obj == nil and 
                context.ret_reg.is_a?(OpVarImmidiateAddress) then
              objid = (context.ret_reg.value >> 1)
              obj = ObjectSpace._id2ref(objid)
            end
            
            if obj then
              idxnode = @arguments[3]
              index = nil
              if idxnode.is_a?(ConstantRefNode)
                idxnode = idxnode.value_node
              end
              
              if idxnode.is_a?(LiteralNode)
                index = idxnode.value
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

      class SendInstanceMemory<SendNode
        add_special_send_node :instance

        def collect_candidate_type_regident(context, slf)
          if YTL::Memory.is_a?(slf.ruby_type) then
            
            slfnode = @arguments[2]
            if slf.ruby_type.is_a?(Class) then
              case slfnode
              when ConstantRefNode
                case slfnode.value_node
                when ClassTopNode
                  clstop = slfnode.value_node
                  tt = RubyType::BaseType.from_ruby_class(clstop.klass_object)
                  @type_list.add_type(context.to_signature, tt)
                  
                else
                  raise "Unkown node type in constant #{slfnode.value_node.class}"
                end
                
              else
                raise "Unkonwn node type #{@arguments[2].class} "
              end
            end
            context

          else
            super
          end
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
