class Fixnum
  def times
    i = 0
    while i < self
      yield i
      i = i + 1
    end

    self
  end
end

10.times do |i|
  i.times do |j|
    p i
    j.times do |k|
      p k
    end
  end
end
