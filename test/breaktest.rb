def test0
  begin
    return
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
    return
  end
  p "bar2"
end

def test3
  begin
    [1, 2, 3].each do |n|
      p n
      return
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


test0

test1
test2

test3
test4

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
