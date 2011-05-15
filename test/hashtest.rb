a = Hash.new
a[:a] = 1
a[:b] = 2

p a[:a]
p a[:b]
p a[:c]

b = {:a => 1, :b => 3, 1 => :c}
p b
p b[:a]
p b[:b]
p b[3]


