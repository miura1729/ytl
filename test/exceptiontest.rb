def foo
  begin
    a = 1
    p "a"
    raise ArgumentError.new
  rescue ArgumentError
    p "index"
    p $!
  else
    p "foo0"
  ensure
    p "foo"
  end

  p "aaa"

  begin
    begin
      b = 2
      raise IndexError.new
    rescue ArgumentError
      p "a"
    end
  rescue IndexError
    p "index2"
  end
end

begin
  foo
rescue ArgumentError
  p "bar"
ensure
  if ArgumentError === ArgumentError.new
    p "end"
  end
end

p "end1"
