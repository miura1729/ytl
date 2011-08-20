# runtime library written in ytl
<<-'EOS'
#
class Module
  def attr(*x)
    x.each do |ele|
      eval "def #{ele}; @#{ele} ; end"
    end
  end

  def attr_accessor(*x)
    x.each do |ele|
      eval "def #{ele}; @#{ele} ; end\n"
      eval "def #{ele}=(val); @#{ele} = val ; end"
    end
  end
end

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

  def collect
    res = []
    i = 0
    e = self.size
    while i < e
      res[i] = yield self[i]
      i = i + 1
    end

    res
  end

  def map
    res = []
    i = 0
    e = self.size
    while i < e
      res[i] = yield self[i]
      i = i + 1
    end

    res
  end

  def at(idx)
    self[idx]
  end
end

class Range
  def each
    i = self.first
    e = self.last
    if self.exclude_end? then
      while i < e
        yield i
        i = i + 1
      end
    else
      while i <= e
        yield i
        i = i + 1
      end
    end

    self
  end

  def to_a
    i = self.first
    e = self.last
    res = []
    if self.exclude_end? then
      while i < e
        res.push i
        i = i + 1
      end
    else
      while i <= e
        res.push i
        i = i + 1
      end
    end

    res
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

  def upto(n)
    i = self
    while i <= n
      yield i
      i = i + 1
    end

    self
  end

  def downto(n)
    i = self
    while i >= n
      yield i
      i = i - 1
    end

    self
  end

  def step(max, st)
    i = self
    if st > 0 then
      while i <= max
        yield i
        i = i + st
      end
    else
      while i >= max
        yield i
        i = i + st
      end
    end

    self
  end

  def **(n)
    a = 1
    while n > 0
      a = a * self
      n = n - 1
    end
    a
  end
end

EOS

