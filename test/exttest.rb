# Please Execute 
# ruby -I lib lib/ytl.rb -r runtime/type.rb test/exttest.rb
module YTL
  class Memory
  end
end

module YTLJit
  module AsmType
  end
end

a = YTL::Memory.instance
b = 0x106667b8
p YTLJit::AsmType::VALUE
p YTLJit::AsmType::RBasic[:klass]
p YTLJit::AsmType::RString[:as][:heap][:len]
p YTLJit::AsmType::RString[:basic][:flags]
p a[b, :machine_word]
p a[b, :float]
#p a[0x106667b8, YTLJit::AsmType::RString[:as][:heap][:ptr]]
p a[b, YTLJit::AsmType::RString[:basic][:flags]]
p a[b, YTLJit::AsmType::RString[:as][:heap][:len]]
p a[b, :machine_word]
