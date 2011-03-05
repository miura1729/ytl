def test0
  begin
    return
  ensure
    p "BAR"
  end
end

def test1
  [1, 2, 3].each do |n|
    p n
    next
  end
  p "foo"
end

def test2
  [1, 2, 3].each do |n|
    p n
    return
  end
  p "foo"
end

def test3
  begin
    [1, 2, 3].each do |n|
      p n
      return
    end
    p "foo"
  ensure
    p "bar"
  end
end

test0

test1
test2

test3
