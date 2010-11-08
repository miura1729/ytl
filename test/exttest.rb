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
p YTLJit::AsmType::VALUE
p YTLJit::AsmType::RBasic[:klass]
p YTLJit::AsmType::RString[:as][:heap][:len]
p YTLJit::AsmType::RString[:basic][:flags]
p a[0x106667b8, :machine_word]
p a[0x106667b8, :float]
#p a[0x106667b8, YTLJit::AsmType::RString[:as][:heap][:ptr]]
p a[0x106667b8, YTLJit::AsmType::RString[:basic][:flags]]
p a[0x106667b8, :machine_word]
