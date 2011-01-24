DAYS_PER_YEAR = 365.24

class Foo
  def initialize(x)
    @a = x * DAYS_PER_YEAR
    @b = 10.0
  end

  attr_accessor :a, :b

  def mov(bodies)
#    bodies[0].a += @a
    p bodies[0].a
  end
end

foo = Foo.new(1.4)
foo.mov([Foo.new(2.8)])
p [Foo.new(2.8)][0]
