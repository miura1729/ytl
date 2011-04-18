require 'ytl'

class String
  def execute_ytl
    YTL::reduced_main(self, {})
  end

  def execute_ruby
    eval(self)
  end
end
                      
