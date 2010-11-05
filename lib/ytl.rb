require 'ytljit'
require 'pp'
require 'optparse'

include YTLJit
module YTL
  include YTLJit
  
  ISEQ_OPTS = {  
    :peephole_optimization    => true,
    :inline_const_cache       => false,
    :specialized_instruction  => false,
  }

  def self.parse_opt(argv)
    ytlopt = {}
    opt = OptionParser.new
    
    opt.on('--disasm', 'Disasemble generated code') do |f|
      ytlopt[:disasm] = f
    end

    opt.on('--dump-yarv', 'Dump YARV byte code') do |f|
      ytlopt[:dump_yarv] = f
    end

    opt.on('--disp-signature', 'Display signature of method') do |f|
      ytlopt[:disp_signature] = f
    end

    opt.on('--dump-context', 'Dump context(registor/stack) for debug') do |f|
      ytlopt[:dump_context] = f
    end

    opt.on('--write-code [=FILE]', 'Write generating code') do |f|
      ytlopt[:write_code] = f
    end

    opt.on('--write-node-before-type-inference [=FILE]', 
           'Write node of before type inference') do |f|
      ytlopt[:write_node_before_ti] = f
    end

    opt.on('--write-node-after-type-inference [=FILE]', 
           'Write node of after type inference') do |f|
      ytlopt[:write_node_after_ti] = f
    end

    opt.parse!(argv)
    ytlopt
  end
  
  def self.main(options)
    is = RubyVM::InstructionSequence.compile(File.read(ARGV[0]), ARGV[0], 
                                             "", 0, ISEQ_OPTS).to_a
    iseq = VMLib::InstSeqTree.new(nil, is)
    if options[:dump_yarv] then
      pp iseq
    end
    
    tr = VM::YARVTranslatorSimple.new([iseq])
    tnode = tr.translate
    ci_context = VM::CollectInfoContext.new(tnode)
    tnode.collect_info(ci_context)

    if fn = options[:write_node_before_ti] then
      File.open(fn, "w") do |fp|
        fp.print Marshal.dump(tnode)
      end
    end

    dmylit = VM::Node::LiteralNode.new(tnode, nil)
    arg = [dmylit, dmylit, dmylit]
    sig = []
    arg.each do |ele|
      sig.push RubyType::DefaultType0.new
    end

    ti_context = VM::TypeInferenceContext.new(tnode)
    begin
      tnode.collect_candidate_type(ti_context, arg, sig)
    end until ti_context.convergent
    ti_context = tnode.collect_candidate_type(ti_context, arg, sig)
    
    c_context = VM::CompileContext.new(tnode)
    c_context.options = options
    c_context = tnode.compile(c_context)

    if fn = options[:write_node_after_ti] then
      File.open(fn, "w") do |fp|
        fp.print Marshal.dump(tnode)
      end
    end

    if options[:disasm] then
      tnode.code_space_tab.each do |cs|
        cs.fill_disasm_cache
      end
      tnode.code_space.disassemble
    end

    tcs = tnode.code_space
    tcs.call(tcs.base_address)
  end
end

YTL::main(YTL::parse_opt(ARGV))
