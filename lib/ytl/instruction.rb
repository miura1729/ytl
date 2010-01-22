# -*- coding: cp932 -*-
#
#  instruction.rb - structured bytecode library
#
#
module VMLib
  class InstSeqTree
    Headers = %w(magic major_version minor_version format_type
                 misc name filename type locals args exception_table)
#
#  call-seq:
#     VMLib::InstSeqTree.new(parent, iseq)
#        parent  Partent of InstSeqTree
#                For example, when you will construct InstSeqTree of
#                the method body, you must 'parent' is InstSeqTree of definition
#                code of the method.
#                If parent is none, 'parent' is nil.
#        iseq    Instruction Sequence, Normally the result of 
#                VM::InstructionSequence.compile(...) or 
#                VM::InstructionSequence.compile_file(...)
    def initialize(parent = nil, iseq = nil, info = [nil, nil, [], nil])
      @info = info
      @klasses = {}
      @methodes = {}
      @blockes = {}
      @lblock = {}
      @lblock[nil] = []
      @lblock_list = [nil]
      
      @header = {}
      @body = nil
      @parent = parent
      @cur_send_no = 0

      Headers.each do |name|
        @header[name] = nil
      end
      
      if iseq then
        init_from_ary(iseq.to_a)
      end
    end

    attr :header
    attr :klasses
    attr :methodes
    attr :blockes
    attr :lblock
    attr :lblock_list
    attr :body
    attr :parent
    attr :info
    
    def init_from_ary(ary)
      i = 0
      Headers.each do |name|
        @header[name] = ary[i]
        i = i + 1
      end

      @body = ary[i]
      curlblock = nil
      stacktop = nil
      @body.each do |inst|
        if inst.is_a? Integer then
          # Line number
          @lblock[curlblock].push inst

        elsif inst.is_a? Array
          case inst[0]
          when :putobject
            stacktop = inst[1]

          when :defineclass
            if inst[2] then
              obj = InstSeqTree.new(self, nil, [inst[1], nil, nil])
              @klasses[inst[1]] ||= []
              obj.init_from_ary(inst[2])
              @klasses[inst[1]].push obj
            end

          when :definemethod
            if inst[2] then
              obj = InstSeqTree.new(self, nil, [@info[0], inst[1], nil])
              obj.init_from_ary(inst[2])
              @methodes[inst[1]] = obj
            end

          when :putiseq
            if inst[1] then
              obj = InstSeqTree.new(self, nil, [@info[0], stacktop, nil])
              obj.init_from_ary(inst[1])
              @methodes[stacktop] = obj
            end

          # inst[3]�ɂ̓u���b�N���̃��\�b�h�̒ʂ��ԍ�������
          # ���̒ʂ��ԍ��͗�O������return point�̊m��Ȃǂ�
          # �g����B
          when :send
            if inst[3] and inst[3][0] then
              obj = InstSeqTree.new(self, nil, 
                                    [@info[0], @info[1], 
                                     @cur_send_no, @info[3].last])
              if inst[3][0] == "YARVInstructionSequence/SimpleDataFormat" then
                obj.init_from_ary(inst[3])
              else
                obj.init_from_ary(inst[3][0])
              end
              @blockes[@cur_send_no]= obj
              inst[3] = [inst[3], @cur_send_no]
            else
              inst[3] = [nil, @cur_send_no]
            end
            @cur_send_no += 1
            
          when :invokesuper
            if inst[2] then
              obj = InstSeqTree.new(self, nil, [@info[0], @info[1], @cur_send_no])
              obj.init_from_ary(inst[2])
              @blockes[@cur_send_no] = obj
              inst[2] = [inst[3], @cur_send_no]
            else
              inst[2] = [nil, @cur_send_no]
            end
            @cur_send_no += 1
          end

          @lblock[curlblock].push inst
          
        elsif inst.is_a? Symbol
          # Label
          if !@lblock_list.include?(inst) then
            @lblock_list.push inst
          end
          curlblock = inst
          @lblock[curlblock] = []

        else
          raise RuntimeError, inst
        end
      end
    end

    def to_a
      res = []
      Headers.each do |name|
        res.push @header[name]
      end
      
      stacktop = nil
      body = []
      clno = Hash.new(0)
      @lblock_list.each do |ln|
        body.push ln
        @lblock[ln].each do |inst|
          if inst.is_a? Array then
            cinst = inst.clone
            case inst[0]
            when :putobject
              stacktop = inst[1]

            when :defineclass
              if inst[2] then
                cinst[2] = @klasses[inst[1]][clno[inst[1]]].to_a
                clno[inst[1]] += 1
              end
              
            when :definemethod
              if inst[2] then
                cinst[2] = @methodes[inst[1]].to_a
              end
              
            when :putiseq
              if stacktop then
                cinst[1] = @methodes[stacktop].to_a
              end

            when :send
              if inst[3] and inst[3][0] then
                cinst[3] = @blockes[inst[3][1]].to_a
              else
                cinst[3] = nil
              end
              
            when :invokesuper
              if inst[2] and inst[2][0] then
                cinst[2] = @blockes[inst[2][1]].to_a
              else
                cinst[2] = nil
              end
            end
            body.push cinst
          else
            body.push inst
          end
        end
      end
      
      res.push body
      res
    end

    def merge_other_iseq(oiseq)
      oiseq.blockes.each do |name, blk|
        @blockes[name] = blk
      end

      oiseq.methodes.each do |name, mth|
        @methodes[name] = mth
      end

      oiseq.klasses.each do |name, mth|
        @klasses[name] = mth
      end

      self
    end

    def clear_related_iseq
      @blockes = {}
      @methodes = {}
      @klasses = {}
    end

    def traverse_code(info, action)
      fn = @header['filename']
      action.call(self, info)

      @blockes.each do |sno, cont|
        blst = info[4]
        blst.push sno
        cont.traverse_code([info[0], info[1], blst, fn], action)
        blst.pop
      end

      @methodes.each do |name, cont|
        cont.traverse_code([info[0], name, [], fn], action)
      end

      @klasses.each do |name, carray|
        linfo = ["#{info[0]}::#{name}", nil, [], fn]
        carray.each do |cont|
          cont.traverse_code(linfo, action)
        end
      end
    end

    def traverse_code_block(info, action)
      fn = @header['filename']
      action.call(self, info)

      @blockes.each do |sno, cont|
        blst = info[4]
        blst.push sno
        cont.traverse_code([info[0], info[1], blst, fn], action)
        blst.pop
      end
    end

  end
end

