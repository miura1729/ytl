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
        pself = self.pself
        self.merged_join(pself.self_merge(self.cself, pself))
      end
    end
  end
end

EOS

