def attr(x)
  eval "def #{x}; @#{x}; end"
end

attr :foo

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
