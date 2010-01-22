module YTL
  class AstGenerater
    def initialize
      @iseqts = []

      @expstack = []
      @ctrstack = []

      @global_load_path = $LOAD_PATH
      @global_load_features = $LOAD_FEATURE

      @lex_context = LexicalContext(self)
    end

    def add_vmcode(vmcode, parent = nil)
      iseqt = VMLib::InstSeqTree.new(parent, vmcode)
      @iseqts.push 
    end

    def generate
      action = lambda {|code, info|
        dispatch(code, info)
      }
      @iseqts.each do |iseqt|
        iseqt.traverse_code([nil, nil, [], nil], action)
      end
    end
    
    def dispatch(code, info)
      
    end
  end
end
