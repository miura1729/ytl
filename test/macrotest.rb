class Module
  def myattr(*x)
    str = ""
    x.each do |e|
      eval "def #{e}; @#{e}; end\n"
    end
  end
end

class Foo
  def myattr(x)
    p x
  end
end

myattr :foo, :bar
a = Foo.new.myattr("abc")

# Can't psss this test yet
=begin

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

p fact_inline(5)
=end
