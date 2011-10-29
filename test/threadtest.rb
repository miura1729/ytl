# ytl -r runtime/thread.rb threadtest.rb
p "start"
a = 0
def fib(x)
  if x < 2 then
    1
  else
    fib(x - 1) + fib(x -2)
  end
end

class Foo
  def initialize
    @res = 0
  end

  attr :res

  def foo
    YTLJit::Runtime::Thread.new do |arg|
#      p self
      @res = fib(30)
    end
  end
end

p self
foo = Foo.new
th = foo.foo
p "computing fib 2 threads"
p fib(30)
# p th
p foo.res
th.join
p foo.res
