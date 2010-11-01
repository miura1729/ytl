module YTL
  class Memory
  end
end

a = YTL::Memory.instance;p a[0x106667b8, :machine_word]
p a[0x106667b8, :float]
