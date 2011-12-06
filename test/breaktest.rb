def test0
  begin
    return false
  ensure
    p "BAR0"
  end
end

def test1
  [1, 2, 3].each do |n|
    p n
    next
  end
  p "foo1"
end

def test2
  [1, 2, 3].each do |n|
    p n
    return false
  end
  p "bar2"
end

def test3
  begin
    [1, 2, 3].each do |n|
      p n
      return false
    end
    p "foo3"
  ensure
    p "bar3"
  end
end

def test4
  begin
    [1, 2, 3].each do |n|
      p n
      break
    end
    p "foo4"
  ensure
    p "bar4"
  end
end


p test0

p test1
p test2

p test3
p test4

=begin
# Not support yet

def test5
  begin
    [1, 2, 3].each do |n|
      p n
      next
    end
    p "foo5"
  ensure
    p "bar5"
  end
end

def test6
  begin
    [1, 2, 3].each do |n|
      p n
      redo
    end
    p "foo"
  ensure
    p "bar"
  end
end
=end

def test7
  [1, 2, 3].each do |m|
    [4, 5, 6].each do |n|
      p m
      p n
      return false if n + m == 7
    end
    p "bar7-1"
  end
  p "bar7-2"
end

p test7
