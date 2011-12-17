include YTLJit
include InternalRubyType

tr_context.import_object(YTLJit, :AsmType, YTLJit::AsmType)
tr_context.import_object(YTLJit, :Runtime, YTLJit::Runtime)
tr_context.import_object(YTLJit::AsmType, :VALUE, VALUE)
tr_context.import_object(YTLJit::AsmType, :P_CHAR, P_CHAR)
tr_context.import_object(YTLJit::AsmType, :RBasic, RBasic)
tr_context.import_object(YTLJit::AsmType, :RString, RString)
tr_context.import_object(YTLJit::AsmType, :RFloat, RFloat)
tr_context.import_object(YTLJit::Runtime, :Arena, Runtime::Arena)
""
