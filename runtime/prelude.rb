# runtime library written in ytl
<<-'EOS'
#
class Array
  def each
    i = 0
    e = self.size
    while i < e
      yield self[i]
      i = i + 1
    end

    self
  end
end

class Range
  def each
    i = self.first
    e = self.last
    if self.exclude_end? then
      while i <= e
        yield i
        i = i + 1
      end
    else
      while i < e
        yield i
        i = i + 1
      end
   end

   e
  end
end

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

EOS

