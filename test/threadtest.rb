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

th = YTLJit::Runtime::Thread.new do |arg|
  a = fib(39)
end

p "computing fib 2 threads"
p fib(38)
th.join
p a
