include YTLJit
include InternalRubyType
p Runtime::Arena.new.address

tr_context.import_object(YTLJit::AsmType, :VALUE, VALUE)
tr_context.import_object(YTLJit::AsmType, :P_CHAR, P_CHAR)
tr_context.import_object(YTLJit::AsmType, :RBasic, RBasic)
tr_context.import_object(YTLJit::AsmType, :RString, RString)
tr_context.import_object(YTLJit::AsmType, :RFloat, RFloat)
tr_context.import_object(YTLJit::Runtime, :Arena, Runtime::Arena)
""
