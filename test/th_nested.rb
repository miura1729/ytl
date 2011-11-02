class Foo
  def initialize
    @res = 0
  end

  attr_accessor :res

  def foo
    th = nil
    th2 = YTLJit::Runtime::Thread.new do
      th = YTLJit::Runtime::Thread.new do
        @res = 2
      end
      @res = 1
    end
    while th == nil
    end
    th.join
    p @res
    th2.join
    p @res
  end

  def self_merge(cself, pself)
    pself.res = pself.res + cself.res
    pself
  end
end

Foo.new.foo

