# ast.rb
#   Define nodes of AST
#

module YTL
  #
  # The base class of node of AST.
  #
  #  You must inherit the class when you define node class of AST.
  #  You must define following method
  #    type_inference_first
  #      Call first time of type inference. The method will construct
  #      relation of variable, expression, literal.
  #    type_inference_next
  #      When type inference is imcomplete by type_inference_first, 
  #      call the method. The method will complete using typing information
  #      by previous type inference.
  #    generate_code
  class BaseNode
    # Construct node object
    # When you inherit BaseNode, you must put 'super' in end of initlaize 
    # method.
    # Arguments
    #    code  : YARV code corresponding the node. It is array.
    #    lcontext : Lexical context, see LexicalContext class in context.rb.
    #
    # Results
    #    Updated lexical context
    def initialize(code, lcontext)
      @code = code
      lcontext
    end

    def type_inference_first(dcontext)
      dcontext
    end

    def type_inference_next(dcontext)
      dcontext
    end

    def generate_code(dcontext)
      dcontext
    end
  end
  
  # Line number
  class NumberNode<BaseNode
  end

  # getlocal
  #   
  class GetLocalNode<BaseNode
    def initialize(code, lcontext)
      super
    end

    def type_inference_first(dcontext)
    end

    def type_inference_next(dcontext)
    end

    def generate_code(dcontext)
    end
  end
end

