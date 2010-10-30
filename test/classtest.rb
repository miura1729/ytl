class Foo
  def bar
    p "Foo#bar"
  end

  def initialize
    p "bar"
  end
end

a = Foo.new
a.bar

p Foo.new
