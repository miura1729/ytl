require 'ytljit'
require 'pp'

include YTLJit

opts = {  
  :peephole_optimization    => true,
  :inline_const_cache       => false,
  :specialized_instruction  => false,}


is = RubyVM::InstructionSequence.compile(File.read(ARGV[0]), ARGV[0], "", 0,
                                         opts).to_a
iseq = VMLib::InstSeqTree.new(nil, is)
# pp iseq

tr = VM::YARVTranslatorSimple.new([iseq])
tnode = tr.translate
ci_context = VM::CollectInfoContext.new(tnode)
tnode.collect_info(ci_context)

ti_context = VM::TypeInferenceContext.new(tnode)
begin
  tnode.collect_candidate_type(ti_context, [], [])
end until ti_context.convergent
ti_context = tnode.collect_candidate_type(ti_context, [], [])

c_context = VM::CompileContext.new(tnode)
c_context = tnode.compile(c_context)
tcs = tnode.code_space
tcs.call(tcs.base_address)

