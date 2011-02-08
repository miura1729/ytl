# -*- coding: cp932 -*-
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

  def step(max, st)
    i = self
    while i < max
       yield i
      i = i + st
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

