module YTL
  class TypedData
  end
end

module YTLJit
  module VM
    module Node
      class  SendElementRefAccMemNode<SendElementRefNode
        include SendUtil
        add_special_send_node :[]
        def collect_candidate_type_regident(context, slf)
          if slf.ruby_type == YTL::TypedData then
          else
            p "foo"
            super
          end
        end
      end
    end
  end
end
