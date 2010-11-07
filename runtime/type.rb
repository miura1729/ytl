include YTLJit
VALUE = AsmType::MACHINE_WORD
P_CHAR = AsmType::Pointer.new(AsmType::INT8)

RBasic = AsmType::Struct.new(
              VALUE, :flags,
              VALUE, :klass
             )
RString = AsmType::Struct.new(
               RBasic, :basic,
               AsmType::Union.new(
                AsmType::Struct.new(
                 AsmType::INT32, :len,
                 P_CHAR, :ptr,
                 AsmType::Union.new(
                   AsmType::INT32, :capa,
                   VALUE, :shared,
                 ), :aux
                ), :heap,
                AsmType::Array.new(
                   AsmType::INT8,
                   24
                ), :ary
               ), :as
              )

RFloat = AsmType::Struct.new(
               RBasic, :basic,
               AsmType::DOUBLE, :float_value
              )

EMBEDER_FLAG = (1 << 13)

tr_context.import_object(YTLJit::AsmType, :VALUE, VALUE)
tr_context.import_object(YTLJit::AsmType, :P_CHAR, P_CHAR)
tr_context.import_object(YTLJit::AsmType, :RBasic, RBasic)
tr_context.import_object(YTLJit::AsmType, :RString, RString)
tr_context.import_object(YTLJit::AsmType, :RFloat, RFloat)
""
