require 'ytljit'
require 'ytl/accmem.rb'
require 'ytl/macro.rb'
require 'ytl/importobj.rb'
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
    prelude = File.join(File.dirname(__FILE__), "..", "runtime", "prelude.rb")
    ytlopt[:execute_before_compile] = [prelude]
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

    opt.on('--write-code =FILE', 'Write generating code') do |f|
      ytlopt[:write_code] = f
    end

    opt.on('--write-node-before-type-inference =FILE', 
           'Write node of before type inference') do |f|
      ytlopt[:write_node_before_ti] = f
    end

    opt.on('--write-node-after-type-inference =FILE', 
           'Write node of after type inference') do |f|
      ytlopt[:write_node_after_ti] = f
    end

    opt.on('-r FILE', '--execute-before-compile =FILE', 
           'Execute ruby program (execute by CRuby)') do |f|
      ytlopt[:execute_before_compile].push f
    end

    opt.parse!(argv)
    ytlopt
  end

  def self.dump_node(tnode, fn)
    if defined? yield then
      yield
    end
    File.open(fn, "w") do |fp|
      ClassClassWrapper.instance_tab.keys.each do |klass|
        if !klass.is_a?(ClassClassWrapper) then
          fp.print "class #{klass.name}; end\n"
        end
      end

      fp.print "Marshal.load(<<'EOS')\n"
      fp.print Marshal.dump(tnode)
      fp.print "\n"
      fp.print "EOS\n"
    end
  end

  def self.main(options)
    tr_context = VM::YARVContext.new
    progs = []

    import_ruby_object(tr_context)
    options[:execute_before_compile].each do |fn|
      rf = File.read(fn)
      prog = eval(rf)
      progs.push prog
      is = RubyVM::InstructionSequence.compile(prog, ARGV[0], 
                                             "", 0, ISEQ_OPTS).to_a
      iseq = VMLib::InstSeqTree.new(nil, is)
      tr = VM::YARVTranslatorCRubyObject.new([iseq])
      tr.translate(tr_context)
    end

    tnode = nil
    case File.extname(ARGV[0])
    when ".ytl"
      File.open(ARGV[0]) do |fp|
        tnode = eval(fp.read, TOPLEVEL_BINDING)
      end
      tnode.update_after_restore
      if tnode.code_space then
        tnode.code_space.call(tnode.code_space.base_address)
        return
      end

    when ".rb"
      prog = File.read(ARGV[0])
      is = RubyVM::InstructionSequence.compile(prog, ARGV[0], 
                                               "", 0, ISEQ_OPTS).to_a
      iseq = VMLib::InstSeqTree.new(nil, is)
      if options[:dump_yarv] then
        pp iseq
      end
    
      tr = VM::YARVTranslatorCRubyObject.new([iseq])
      tnode = tr.translate(tr_context)
      ci_context = VM::CollectInfoContext.new(tnode)
      tnode.collect_info(ci_context)
      
      if fn = options[:write_node_before_ti] then
        dump_node(tnode, fn)
      end
    end

    dmylit = VM::Node::LiteralNode.new(tnode, nil)
    arg = [dmylit, dmylit, dmylit]
    sig = []
    arg.each do |ele|
      sig.push RubyType::BaseType.from_ruby_class(NilClass)
    end

    ti_context = VM::TypeInferenceContext.new(tnode)
    begin
      tnode.collect_candidate_type(ti_context, arg, sig)
    end until ti_context.convergent
    ti_context = tnode.collect_candidate_type(ti_context, arg, sig)

    if fn = options[:write_node_after_ti] then
      dump_node(tnode, fn)
    end
    
    c_context = VM::CompileContext.new(tnode)
    c_context.current_method_signature.push sig
    c_context.options = options
    c_context = tnode.compile(c_context)
    tnode.make_frame_struct_tab

    if fn = options[:write_code] then
      dump_node(tnode, fn) {
        tnode.code_store_hook
      }
    end

    if options[:disasm] then
      tnode.code_space_tab.each do |cs|
        cs.fill_disasm_cache
      end
      tnode.code_space.disassemble
    end

    tcs = tnode.code_space
    STDOUT.flush
    tcs.call(tcs.base_address)
  end
end

if __FILE__ == $0 then
  YTL::main(YTL::parse_opt(ARGV))
end
