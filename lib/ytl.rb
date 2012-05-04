require 'ytljit'
require 'ytl/accmem.rb'
require 'ytl/macro.rb'
require 'ytl/importobj.rb'
require 'pp'
require 'optparse'

include YTLJit
module YTL
  include YTLJit

  VERSION = "0.0.6"
  
  ISEQ_OPTS = {  
    :peephole_optimization    => true,
    :inline_const_cache       => false,
    :specialized_instruction  => false,
  }

  def self.parse_opt(argv)
    ytlopt = {}
    ytlopt[:execute_before_compile] = []
    opt = OptionParser.new
    
    opt.on('-I PATH', 
           'Add require/load path') do |f|
      $_YTL_LOAD_PATH.push f
    end

    opt.on('--disasm', 'Disasemble generated code') do |f|
      ytlopt[:disasm] = f
    end
    
    opt.on('--dump-yarv', 'Dump YARV byte code') do |f|
      ytlopt[:dump_yarv] = f
    end
    
    opt.on('--disp-signature', 'Display signature of method') do |f|
      ytlopt[:disp_signature] = f
    end

    opt.on('--insert-signature-comment', 'insert comment of signature') do |f|
      ytlopt[:insert_signature_comment] = f
    end
    
    opt.on('--dump-context', 'Dump context(registor/stack) for debug') do |f|
      ytlopt[:dump_context] = f
    end
    
    opt.on('-o FILE', '--write-code =FILE', 
           'Write generating naitive code and node objects') do |f|
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
    
    opt.on('-c', '--compile-only', 
           'Stop when compile finished (not execute compiled code)') do |f|
      ytlopt[:compile_only] = f
    end
    
    opt.on('--compile-array-as-unboxed', 
           'Compile Array as unboxed if nesseary(not excape, not use special methods)') do |f|
      ytlopt[:compile_array_as_uboxed] = f
    end

    opt.on('--inline-block', 
           'Inline block') do |f|
      ytlopt[:inline_block] = f
    end
    
    opt.parse!(argv)
    ytlopt
  end

  def self.prelude_iseq
    prelude = File.join(File.dirname(__FILE__), "..", "runtime", "prelude.rb")
    rf = File.read(prelude)
    prog = eval(rf)
    is = RubyVM::InstructionSequence.compile(prog, prelude, 
                                             "", 1, ISEQ_OPTS).to_a
    VMLib::InstSeqTree.new(nil, is)
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
    
  def self.reduced_main(prog, options)
    tr_context = VM::YARVContext.new
    tr_context.options = options
    
    import_ruby_object(tr_context)
    
    tnode = nil
    is = RubyVM::InstructionSequence.compile(prog, ARGV[0], 
                                             "", 1, ISEQ_OPTS).to_a
    iseq = VMLib::InstSeqTree.new(nil, is)
    iseqs = [prelude_iseq, iseq]
    
    tr = VM::YARVTranslatorCRubyObject.new(iseqs)
    tnode = tr.translate(tr_context)
    
    ci_context = VM::CollectInfoContext.new(tnode)
    ci_context.options = options
    tnode.collect_info(ci_context)
    
    dmylit = VM::Node::LiteralNode.new(tnode, nil)
    dmylit2 = VM::Node::LiteralNode.new(tnode, Object.new)
    arg = [dmylit, dmylit, dmylit]
    sig = []
    arg.each do |ele|
      sig.push RubyType::BaseType.from_ruby_class(NilClass)
    end
    
    ti_context = VM::TypeInferenceContext.new(tnode)
    ti_context.options = options
    begin
      tnode.collect_candidate_type(ti_context, arg, sig)
    end until ti_context.convergent
    ti_context = tnode.collect_candidate_type(ti_context, arg, sig)
    
    c_context = VM::CompileContext.new(tnode)
    c_context.current_method_signature.push sig
    c_context.options = options
    c_context = tnode.compile(c_context)
    tnode.make_frame_struct_tab
    
    tcs = tnode.code_space
    tcs.call(tcs.base_address)
  end
    
  def self.main(options)
    tr_context = VM::YARVContext.new
    tr_context.options = options
    progs = []
    
    import_ruby_object(tr_context)
    options[:execute_before_compile].each do |fn|
      rf = File.read(fn)
      prog = eval(rf)
      progs.push prog
      is = RubyVM::InstructionSequence.compile(prog, fn, 
                                               "", 1, ISEQ_OPTS).to_a
      iseq = VMLib::InstSeqTree.new(nil, is)
      tr = VM::YARVTranslatorCRubyObject.new([iseq])
      tr_context.current_file_name = fn
      tr.translate(tr_context)
    end
    
    tnode = nil
    progarray = nil
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
      if options[:insert_signature_comment] then
        progarray = prog.split(/\n/)
      end
      is = RubyVM::InstructionSequence.compile(prog, ARGV[0], 
                                               "", 1, ISEQ_OPTS).to_a
      iseq = VMLib::InstSeqTree.new(nil, is)
      if options[:dump_yarv] then
        pp iseq
      end
      iseqs = [prelude_iseq, iseq]
      
      tr = VM::YARVTranslatorCRubyObject.new(iseqs)
      tr_context.current_file_name = ARGV[0]
      tnode = tr.translate(tr_context)
    end
    $0 = ARGV[0]
    file_name = ARGV[0]
    ARGV.shift
    
    ci_context = VM::CollectInfoContext.new(tnode)
    ci_context.options = options
    tnode.collect_info(ci_context)
    
    if fn = options[:write_node_before_ti] then
      dump_node(tnode, fn)
    end
    
    dmylit = VM::Node::LiteralNode.new(tnode, nil)
    dmylit2 = VM::Node::LiteralNode.new(tnode, Object.new)
    arg = [dmylit, dmylit, dmylit]
    sig = []
    arg.each do |ele|
      sig.push RubyType::BaseType.from_ruby_class(NilClass)
    end
    
    ti_context = VM::TypeInferenceContext.new(tnode)
    ti_context.options = options
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
    
    if options[:insert_signature_comment] then
      progarray.each_with_index do |lin, lno|
        if cinfos = c_context.comment[file_name][lno] # and cinfo[0] then
          cinfos.each do |cinfo|
            case cinfo[0]
            when 1
              print "#  #{cinfo[1]} \n"
              cinfo[2..-1].each do |sig, res|
                print "#     #{sig[3..-1]} -> #{res.inspect} \n"
                print "#     self    #{sig[2].inspect} \n"
                print "#     block   #{sig[1].inspect} \n"
                print "# \n"
              end
            when 2
              print "# #{cinfo[1]} #{cinfo[2].inspect} \n"
            when 3
              if cinfo[1] == :local_export then
                print "# please do't unroll stack \n"
              end
            end
          end
        end
        print lin, "\n"
      end
    end

    tcs = tnode.code_space
    STDOUT.flush
    if !options[:compile_only] then
      tcs.call(tcs.base_address)
    end
  end
end

Version = "#{YTL::VERSION} (ytljit #{YTLJit::VERSION})"

if __FILE__ == $0 then
  # Global variable for require
  $_YTL_LOAD_PATH = $LOAD_PATH
  $_YTL_FEATURES = []

  YTL::main(YTL::parse_opt(ARGV))
end
