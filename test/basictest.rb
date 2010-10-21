def id (x)
  x
end

p id(1)
p id(1.9)

def array
  [1, 2, 3][0] + [1, 2, 3][1]  
end
p array

def fib(x)
  if x < 2 then
    1
  else
    fib(x + -1) + fib(x + -2)
  end
end

p fib(35)

=begin
def fib2(x)
  if x < 2 then
    1.0
  else
    fib2(x + -1) + fib2(x + -2)
  end
end

p fib2(35)
=end

def blk0(x)
  yield(x) + 2
end

def blk1(x)
  yield(x) + 10
end

p blk0(1) {|a| a + 1}
p blk1(1) {|a| blk0(a) {|b| b + a}}
  
