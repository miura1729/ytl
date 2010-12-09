def id (x)
  x
end

p id(1)
p id(1.9)

def array
  a = [3, 5, 6]
  p a
  a[1] = 1
  p a
  [1, 2, 3][0] + [1, 2, 3][1]  
end
p array

def fib(x)
  if x < 2 then
    1
  else
    fib(x-1) + fib(x-2)
  end
end

p fib(35)

def fib2(x)
  if x < 2 then
    1.0
  else
    fib2(x-1) + fib2(x-2)
  end
end

p fib2(35)

def blk0(x)
  yield(x) + 2
end

def blk1(x)
  yield(x) + 10
end

p blk0(1) {|a| a + 1}
p blk1(1) {|a| blk0(a) {|b| b + a}}

def blk3
  yield
end

p id(blk3 { "abc"})
p id(blk3 { 1 })

def mul(x, y)
  x * y
end

p mul(30, 40)
p mul(30, -40)
p mul(-30, 40)
p mul(-30, -40)
p mul(30.0, 40.0)
p mul(30.0, -40.0)
p mul(-30.0, 40.0)
p mul(-30.0, -40.0)

def div(x, y)
  x / y
end

p div(30, 4)
p div(30, -4)
p div(-30, 4)
p div(-30, -4)
p div(30.0, 7.0)
p div(30.0, -7.0)
p div(-30.0, 7.0)
p div(-30.0, -7.0)
p div(35, 7)
p div(35, -7)
p div(-35, 7)
p div(-35, -7)

p 1 < 1
p 1 > 1
p 1 <= 1
p 1 >= 1

p 1 < 2
p 1 > 2
p 1 <= 2
p 1 >= 2

p 1.0 < 2.0
p 1.0 > 2.0
p 1.0 <= 2.0
p 1.0 >= 2.0

p 1.0 < 1e-17
p 1.0 > 1e-17
p 1.0 <= 1e-17
p 3.0 > 2.0
p :foo
p :foo == :foo
p :foo == :bar
p :foo != :foo
p :foo != :bar

def multi_type_var
  a = 1
  p a
  a = "a"
  p a
  a = 1.0
  p a
#  p 1.0
end

multi_type_var

def test_while
  i = 10
  j = 0
  k = 10
  while i > 0
    while k > 0
      j = j + i
      k = k - 1
    end
    i = i - 1
    k = 10
  end
  p j

  i = 10
  j = 0
  while i > 0
    i = i - 1
    j = j + i
  end
  p j
end

test_while

