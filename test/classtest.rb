class Foo
  def bar
    p "Foo#bar"
  end

  def baz
    p "Foo#baz"
    p @a
  end

  def initialize
    @a = 4
    p "initialize Foo"
    p self
  end
end

class Bar<Foo
  p self
  p "foobarbaz"
  def bar
    p "Bar#bar"
  end
end

a = Foo.new
p a
a.bar
a.baz
b = Bar.new
p b
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
