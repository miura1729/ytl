module YTLJit
  module VM
    class ToRubyContext
      def initialize
        @ret_code = [""]
        @jmp_tab = {}
      end

      attr :ret_code
      attr :jmp_tab
    end

    module Node
      class BaseNode
        def to_ruby(context)
          context
        end
      end

      class DummyNode
      end

      class TopNode
      end

      class MethodTopNode
        def to_ruby(context)
          context.ret_code.last << "def #{@name}"
          context.ret_code.push ""
          context = @body.to_ruby(context)
          args = context.ret_code.pop
          if args != "" then
            context.ret_code.last << "(#{args})"
          end
          context = @body.body.to_ruby(context)
          context.ret_code.last << "end\n"
          context
        end
      end

      class BlockTopNode
        def to_ruby(context)
          context.ret_code.last << "{ "
          context.ret_code.push ""
          context = @body.to_ruby(context)
          args = context.ret_code.pop
          if args != "" then
            context.ret_code.last << "| #{args} | \n"
          end
          context.ret_code.last << "state = 0\n"
          context.ret_code.last << "while true\n"
          context.ret_code.last << "case state\n"
          context.ret_code.last << "when 0\n"
          context = @body.body.to_ruby(context)
          context.ret_code.last << "end\n"
          context.ret_code.last << "end\n"
          context.ret_code.last << "}\n"
          context
        end
      end

      class ClassTopNode
      end

      class TopTopNode
      end

      class LocalFrameInfoNode
        def to_ruby(context)
          argpos = 0
          @frame_layout.each do |vinf|
            if vinf.is_a?(LocalVarNode) then
              argpos = argpos + 1
              if argpos > 3 then
                context = vinf.to_ruby(context)
                context.ret_code.last << ", "
              end
            end
          end
          context.ret_code.last.chop!
          context.ret_code.last.chop!

          context
        end
      end

      class LocalVarNode
        def to_ruby(context)
          context.ret_code.last << @name.to_s
          context
        end
      end
      
      class SystemValueNode
      end

      class GuardNode
      end

      class MethodEndNode
      end

      class BlockEndNode
      end

      class ClassEndNode
      end

      class SetResultNode
        def to_ruby(context)
          context.ret_code.last << "return "
          context = @value_node.to_ruby(context)
          context.ret_code.last << "\n"
          @body.to_ruby(context)
        end
      end

      class PhiNode
        def to_ruby(context)
          context.ret_code.last << "value"
          context
        end
      end

      class LocalLabel
        def to_ruby(context)
          context.ret_code.last << "when #{context.jmp_tab[self]}\n"
          @body.to_ruby(context)
        end
      end

      class BranchCommonNode
        def to_ruby_common(context, unlessp)
          nf = false
          if context.jmp_tab[@jmp_to_node] == nil then
            context.jmp_tab[@jmp_to_node] = context.jmp_tab.size + 1
            nf = true
          end
          jlab = context.jmp_tab[@jmp_to_node]

          blab  = context.jmp_tab.size + 1
          context.jmp_tab[@body] = blab

          context.ret_code.push ""
          context = @cond.to_ruby(context)
          cc = context.ret_code.pop
          context.ret_code.last << "if #{cc} then\n"
          if unlessp then
            context.ret_code.last << "state = #{blab}\n"
            context.ret_code.last << "else\n"
            context.ret_code.last << "state = #{jlab}\n"
          else
            context.ret_code.last << "state = #{jlab}\n"
            context.ret_code.last << "else\n"
            context.ret_code.last << "state = #{blab}\n"
          end
          context.ret_code.last << "end\n"
          
          if nf then
            context = @jmp_to_node.to_ruby(context)
          end

          context.ret_code.last << "when #{context.jmp_tab[@body]}\n"
          context = @body.to_ruby(context)
        end
      end

      class BranchIfNode
        def to_ruby(context)
          to_ruby_common(context, false)
        end
      end

      class BranchUnlessNode
        def to_ruby(context)
          to_ruby_common(context, true)
        end
      end

      class JumpNode
        def to_ruby(context)
          nf = false
          if context.jmp_tab[@jmp_to_node] == nil then
            context.jmp_tab[@jmp_to_node] = context.jmp_tab.size + 1
            nf = true
          end
          context.ret_code.last << "state = #{context.jmp_tab[@jmp_to_node]}\n"
          valnode = @jmp_to_node.come_from[self]
          if valnode then
            context.ret_code.push ""
            context = valnode.to_ruby(context)
            val = context.ret_code.pop
            context.ret_code.last << "value = #{val}\n"
          end
          if nf then
            @jmp_to_node.to_ruby(context)
          else
            context
          end
        end
      end

      class LetNode
      end

      class LiteralNode
        def to_ruby(context)
          context.ret_code.last << get_constant_value[0].to_s
          context
        end
      end

      class ClassValueNode
      end

      class SpecialObjectNode
      end

      class YieldNode
      end

      class MethodSelectNode
      end

      class VariableRefCommonNode
      end

      class LocalVarRefCommonNode
      end

      class LocalVarRefNode
        def to_ruby(context)
          cfi = @current_frame_info
          off = cfi.real_offset(@offset)
          lv = cfi.frame_layout[off]
          context.ret_code.last << " #{lv.name.to_s} "
          context
        end
      end

      class SelfRefNode
      end

      class LocalAssignNode
      end

      class InstanceVarRefCommonNode
      end

      class InstanceVarRefNode
      end

      class InstanceVarAssignNode
      end

      class ConstantRefNode
        def to_ruby(context)
          context.ret_code.last << @name.to_s
          context
        end
      end

      class ConstantAssignNode
      end

      class SendNode
        def to_ruby(context)
          context = @arguments[2].to_ruby(context)
          context.ret_code.last << ".#{@func.name}("
          @arguments[3..-1].each do |ae|
            context = ae.to_ruby(context)
            context.ret_code.last << ", "
          end
          context.ret_code.last.chop!
          context.ret_code.last.chop!
          context.ret_code.last << ")"
          context
        end
      end

      class SendDefineMacroNode<SendNode
        add_special_send_node :define_macro
        
        def initialize(parent, func, arguments, op_flag, seqno)
          super
          @entity = nil
          if @arguments[2].get_constant_value == [YTL] then
            @entity = @arguments[1]
            print @entity.to_ruby(ToRubyContext.new).ret_code.last
          end
        end
      end
    end
  end
end
