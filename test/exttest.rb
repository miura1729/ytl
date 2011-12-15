# Please Execute 
# ruby -I lib lib/ytl.rb -r runtime/type.rb test/exttest.rb
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

c = YTLJit::Runtime::Arena.new
a = YTL::Memory.instance
# b = 0x1046ce30
b = c.address
p b
p c
a[b, YTLJit::AsmType::RFloat[:float_value]] = 3.14
p YTLJit::AsmType::VALUE
p YTLJit::AsmType::RBasic[:klass]
p YTLJit::AsmType::RString[:as][:heap][:len]
p YTLJit::AsmType::RString[:basic][:flags]
p YTLJit::AsmType::RFloat[:float_value]
p a[b, :machine_word]
#p a[0x106667b8, YTLJit::AsmType::RString[:as][:heap][:ptr]]
p a[b, :float]
p a[b, YTLJit::AsmType::RString[:basic][:flags]]
p a[b, YTLJit::AsmType::RString[:as][:heap][:len]]
p a[b, YTLJit::AsmType::RFloat[:float_value]]
p a[b, :machine_word]
