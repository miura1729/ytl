class Module
  def myattr(*x)
    str = ""
    x.each do |e|
      eval "def #{e}; @#{e}; end\n"
    end
  end
end

class Foo
  myattr :foo, :bar
  def initialize
    @foo = 1
    @bar = 3
  end
  def myattr(x)
    p x
  end
end

Foo.new.myattr("abc")
p Foo.new.bar

def fact(x)
  if x == 0 then
    1
  else
    x * fact(x - 1)
  end
end

def fact_inline(x)
  eval fact(x)
end

y= 1
p fact_inline(5)
