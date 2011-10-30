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

  attr :res

  def foo
    YTLJit::Runtime::Thread.new do |arg|
      @res = fib(30)
    end
  end

  # Merge method whose return value is self object of joined thread
#=begin
  def self_merge(cself, pself)
    cself
  end
#=end

end

p self
foo = Foo.new
th = foo.foo
p "computing fib 2 threads"
p fib(30)
p th

th.join
p foo.res
