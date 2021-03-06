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

def array2
  b = 3
  a = [3, b, 6]
  p a
  a[1] = 1
  p a
  [1, 2, 2 * 3][0] + [1 * 2, 2 * 4, 3][1]  
end
p array2

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
p blk3 { 1 }

def mul(x, y)
  x * y
end

p "mul"
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

p "div"
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

def rem(x, y)
  x % y
end
p "rem"
p rem(30, 4)
p rem(30, -4)
p rem(-30, 4)
p rem(-30, -4)
p rem(35, 7)
p rem(35, -7)
p rem(-35, 7)
p rem(-35, -7)

p "shift"
p 1 << 2
p 1 << 0
p 3 >> 1
p 1024 >> 3

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

i = 5
a = i..7
p a.first
p a.last
p a
p Range.new(i, 2, false)
p 1...3

def test_poly(a, b, c)
  if c == 1 then
    a + b
  else
    a * b
  end
end

p test_poly(2, 2, 1)
p test_poly(2.0, 2.0, 1)
p test_poly(2, 2, 0)
p test_poly(2.0, 2.0, 0)

p "test for swap"
a = 1
b = 3
a, b = b + 1, a
p a
p b

p "test for is_a?"
p 1.is_a?(Float)
p 1.9.is_a?(Float)
p 1.is_a?(Fixnum)
p 1.is_a?(Object)

def dummy_p(val)
  if val.is_a?(Fixnum)
    p "Fixnum #{val}"
  elsif val.is_a?(Float)
    p "Float #{val}"
  elsif val.is_a?(String)
    p "String #{val}"
  end
end
dummy_p(1)
dummy_p(1.5)
dummy_p("1.5")

def foo2(a, b, c)
  p a
  p b
  p c
  c.disp_type
end
a = [1, "2", 3]
a[1] = "a"
foo2(*a)
b = []
c = [1, "c", 1.2]
#c = [1, 23, 4]
i = 0
c.disp_type
while i < 3 
  b[i] = c[i]
  i = i + 1
end
foo2(*b)

=begin
for i in 1..2
  p i
end

for i in 1...2
  p i
end

=end
 
