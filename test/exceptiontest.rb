def foo
  begin
    a = 1
    raise ArgumentError
  rescue IndexError
    p "index"
  end

  begin
    b = 2
    raise ArgumentError
  rescue IndexError
    p "index2"
  end
end

begin
  foo
rescue ArgumentError
  p "bar"
end
