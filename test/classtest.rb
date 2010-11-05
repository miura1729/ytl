#=begin
class Foo
  def bar
    p "Foo#bar"
  end

  def baz
    p "Foo#baz"
  end

  def initialize
    p "initialize Foo"
    p self
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

class Baz
  def self.alloc
    p "alloc"
  end
  p self
end

p Baz.new
p Baz.alloc

#=end
=begin
class Asd
end

class <<self
end
=end
