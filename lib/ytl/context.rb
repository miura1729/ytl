module YTL
  # 
  class SourceInfo
    def initialize
      @file_name = nil
      @line_number = 0
    end

    attr_accessor :file_name
    attr_accessor :line_number
  end

  class LexicalContext
    def initialize(astgen)
      @astgen = astgen

      @stack = []
      @jump_from = Hash.new {|hash, label| 
        hash[label] = []
      }
      @method_info = MethodInfo.new
      @source_info = SourceInfo.new
    end
    
    attr :stack
    attr :source_info
  end

  class DynamicContext
    def initialize
      @stack = []
    end
  end
end
