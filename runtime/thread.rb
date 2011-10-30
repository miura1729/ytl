require 'ytl/thread.rb'
include YTLJit
include InternalRubyType

tr_context.import_object(YTLJit::Runtime, :Thread, Runtime::Thread)
<<-'EOS'
#

def self_merge(cself, pself)
  cself
end

module YTLJit
  module Runtime
    class Thread
      def join
        self._join
        pslf = self.pself
        newself = pslf.self_merge(self.cself, pslf)
        self._merge(newself)
      end
    end
  end
end

EOS

