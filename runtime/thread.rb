require 'ytl/thread.rb'
include YTLJit
include InternalRubyType

tr_context.import_object(YTLJit::Runtime, :Thread, Runtime::Thread)
""
