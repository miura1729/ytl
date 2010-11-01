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
          if slf.ruby_type == YTL::Memory then
            kind = @arguments[4]
            case kind
            when LiteralNode
              case kind.value
              when :char, :word, :dword, :machine_word
                fixtype = RubyType::BaseType.from_ruby_class(Fixnum)
                add_type(context.to_signature, fixtype)
              when :float
                floattype = RubyType::BaseType.from_ruby_class(Float)
                add_type(context.to_signature, floattype)
              end
            else
              raise "Not support yet #{kind.class} "
            end

            context
          else
            super
          end
        end

        def compile(context)
          slf = @arguments[2]
          slf.decide_type_once(context.to_signature)
          if slf.type.ruby_type == YTL::Memory then
            kind = @arguments[4]
            context = @arguments[3].compile(context)
            asm = context.assembler
            case kind
            when LiteralNode
              case kind.value
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
              end
              
            else
              raise "Not support yet #{kind.class} "
            end
            context.ret_node = self
            context
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
