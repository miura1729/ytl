# Please Execute 
# ruby -I lib lib/ytl.rb -r runtime/type.rb test/exttest.rb
=begin
module YTL
  class Memory
  end
end

module YTLJit
  module AsmType
  end

  module Runtime
  end
end

def id(x)
  x
end
=end
include YTLJit
include YTLJit::AsmType

c = YTLJit::Runtime::Arena.new
a = YTL::Memory.instance
# b = 0x1046ce30
b = c.address
p b
p c
n = [1.9]
foo =  (n[0]).__id__ * 2
p n
p a[foo, RFloat[:float_value]]
a[foo, AsmType::RFloat[:float_value]] = 2.0
p n
p a[foo, RFloat[:float_value]]
a[b, RFloat[:float_value]] = 3.14
p VALUE
p RBasic[:klass]
p RString[:as][:heap][:len]
p RString[:basic][:flags]
p RFloat[:float_value]
p a[b, :machine_word]
#p a[0x106667b8, RString[:as][:heap][:ptr]]
p a[b, :float]
p a[b, RString[:basic][:flags]]
p a[b, RString[:as][:heap][:len]]
p a[b, RFloat[:float_value]]
p a[b, :machine_word]
p "end"
