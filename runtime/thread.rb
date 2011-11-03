require 'ytl/thread.rb'
include YTLJit
include InternalRubyType

tr_context.import_object(YTLJit::Runtime, :Thread, Runtime::Thread)
<<-'EOS'
#

def self_merge(cself, pself)
  cself
end

def pself2=(v)
  nil
end

module YTLJit
  module Runtime
    class Thread
      def join
        _join
        pslf = self_of_caller
        self.pself = pslf
        newself = pslf.self_merge(self.cself, pslf)
        _merge(newself)
      end
    end
  end
end

EOS

