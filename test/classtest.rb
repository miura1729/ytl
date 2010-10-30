class Foo
  def bar
    p "Foo#bar"
  end

  def baz
    p "Foo#baz"
  end

  def initialize
    p "bar"
  end
end

class Bar<Foo
  def bar
    p "Bar#bar"
  end
end

a = Foo.new
a.bar

p Foo.new
b = Bar.new
b.bar
b.baz
