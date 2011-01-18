def myattr(*x)
  str = ""
  x.each do |e|
     str = str + "def #{e}; @#{e}; end\n"
  end
  p str

  eval str
end

myattr :foo, :bar

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
