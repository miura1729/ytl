# ytl -r runtime/thread.rb threadtest.rb
def fib(x)
  if x < 2 then
    1
  else
    fib(x - 1) + fib(x -2)
  end
end

class MultiFib
  def initialize
    @res = 32 # 32 is dummy (not 0 to detect bug)
  end
  attr_accessor :res

  def compute(n)
    th = YTLJit::Runtime::Thread.new do
      @res = fib(n - 1)
    end

    @res = fib(n - 2)

    th.join
    @res
  end

  def self_merge(cself, pself)
    pself.res = pself.res + cself.res
    pself
  end
end

mfib = MultiFib.new
print "computing fib 2 threads fib(40) \n"
p mfib.compute(40)
print "single fib(40)\n"
p fib(40)
