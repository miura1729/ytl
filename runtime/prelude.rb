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

class Object
  def require(fn)
    ff = nil
    $_YTL_LOAD_PATH.each do |dir|
      f = dir + "/" + fn
      
      f2 = f
      if $_YTL_FEATURES.include?(f2) then
        ff = true
        next
      end
      if File.file?(f2) then
        $_YTL_FEATURES.push f2
        fp = open(f2)
        a = fp.read
        eval a
        fp.close
        ff = true
        break
      end

      f2 = f + ".rb"
      if $_YTL_FEATURES.include?(f2) then
        ff = true
        next
      end
      if File.file?(f2) then
p f2
        $_YTL_FEATURES.push f2
        fp = open(f2)
        a = fp.read
        eval a
        fp.close
        ff = true
        break
      end

      f2 = f + ".so"
      if $_YTL_FEATURES.include?(f2) then
        ff = true
        next
      end
      if File.file?(f2) then
        $_YTL_FEATURES.push f2
        # require f2
        ff = true
        break
      end
    end
    if ff == nil then
      raise "No such file #{fn}"
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

  def find
    i = 0
    e = self.size
    while i < e
      if yield self[i] then
        return self[i]
      end
      i = i + 1
    end

    return nil
  end

  def at(idx)
    self[idx]
  end

  def first
    self[0]
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

  def collect
    res = []
    rp =  0
=begin
    self.each do |n|
      res[rp] = yield n
      rp = rp + 1
    end
=end
#=begin
   i = self.first
   e = self.last
    if self.exclude_end? then
      while i < e
        res[rp] = yield i
        rp = rp + 1
        i = i + 1
      end
    else
      while i <= e
        res[rp] = yield i
        rp = rp + 1
        i = i + 1
      end
    end
#=end

    res
  end

  def to_a
    i = self.first
    e = self.last
    res = []
    if self.exclude_end? then
      while i < e
        res << i
        i = i + 1
      end
    else
      while i <= e
        res << i
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

class IO
  def each_line
    while str = gets
      yield str
    end
    nil
  end
end

EOS

