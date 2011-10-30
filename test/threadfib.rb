# ytl -r runtime/thread.rb threadtest.rb
p "start"
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

  attr_accessor :res

  def foo
    YTLJit::Runtime::Thread.new do |arg|
      @res = fib(30)
    end
  end

  def self_merge(cself, pself)
    pself.res = pself.res + cself.res
    pself
  end
end

foo = Foo.new
th = foo.foo
p "computing fib 2 threads fib(32)"
foo.res = fib(31)

th.join
p foo.res  # fib(32)
p "single fib(32)"
p fib(32)
