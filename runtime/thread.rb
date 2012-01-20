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
        _join
        caller = self_of_caller
        newself = caller.self_merge(self.cself, self.pself)
        _merge(newself)
      end
    end
  end
end

EOS

