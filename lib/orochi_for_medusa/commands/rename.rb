require 'orochi_for_medusa/cui'
module OrochiForMedusa::Commands
  class Rename < OrochiForMedusa::Cui
    def option_parser
      opts = OptionParser.new do |opt|
        opt.banner = <<-"EOS".unindent
          NAME
            #{program_name} - Rename record or change attribute

          SYNOPSIS
            #{program_name} [options] id0 value

          DESCRIPTION
            Rename record or change attribute.  Rename a record unless
            option is specified.

          EXAMPLE
            > #{program_name} 20151127162008-525174 "ID-0201(IC-0201?)"

            When you want to set -1 to quantity, insert `--'.
            > #{program_name} 20140827154239-812605 --quantity -- -1
            or 
            > #{program_name} 20140827154239-812605 --key quantity -- -1

            When you want to set affine matrix.
            > #{program_name} 20210914020443-826466 --key affine_matrix "[4.91196e-01,9.81198e-02,2.58169e+03;-8.88352e-02,4.84811e-01,-1.27269e+03;2.4a2902e-08,-4.85341e-09,1.00000e+00]"

          SEE ALSO
            http://dream.misasa.okayama-u.ac.jp
            https://github.com/misasa/orochi-for-medusa/blob/master/lib/orochi_for_medusa/commands/rename.rb

          IMPLEMENTATION
            Orochi, version 9
            Copyright (C) 2015-2020 Okayama University
            License GPLv3+: GNU GPL version 3 or later

          OPTIONS
        EOS
        opt.on("-v", "--[no-]verbose", "Run verbosely") {|v| OPTS[:verbose] = v}
        #opt.on("--stone_type", "Change stone_type") {|v| OPTS[:stone] = v}
        opt.on("--description", "Change description") {|v| OPTS[:description] = v}
        opt.on("--parent_id", "Change parent_id") {|v| OPTS[:parent_id] = v}
        opt.on("--place_id", "Change place_id") {|v| OPTS[:place_id] = v}
        opt.on("--box_id", "Change box_id") {|v| OPTS[:box_id] = v}
        opt.on("--physical_form_id", "Change physical_form_id") {|v| OPTS[:physical_form_id] = v}
        opt.on("--classification_id", "Change classification_id") {|v| OPTS[:classification_id] = v}
        opt.on("--quantity", "Change quantity") {|v| OPTS[:quantity] = v}
        opt.on("--quantity_unit", "Change quantity_unit") {|v| OPTS[:quantity_unit] = v}
        opt.on("--global_id", "Change global_id") {|v| OPTS[:global_id] = v}
        opt.on("--key KEY", "Specify the attribute to change") {|v| OPTS[:key] = v}
      end
      opts
    end

    def rename(id, newparam)
      obj = Record.find(id)
      p obj if OPTS[:verbose]

      if OPTS[:key]
        attrib = OPTS[:key]
        if attrib == 'affine_matrix' || attrib == 'affine_matrix_in_string'
          str = newparam
          str = str.gsub(/\[/,"").gsub(/\]/,"").gsub(/\;/,",").gsub(/\s+/,"")
          tokens = str.split(',')
          vals = tokens.map{|token| token.to_f}
          vals.concat([0,0,1]) if vals.size == 6
          if vals.size == 9
            m = vals
          end
          if m.size == 9
            array =[m[0..2],m[3..5],m[6..8]]
            obj.update_affine_matrix(m)
          else
            raise "invalid affine_matrix (try --key affine_matrix 1,0,0,0,1,0,0,0,1)"
          end
          attrib = 'affine_matrix_in_string'
          obj.attributes.delete(:affine_matrix)
          obj.affine_matrix_in_string = newparam
        else
          obj.send((attrib + '=').to_sym, newparam)
        end
        #obj.send((attrib + '=').to_sym, newparam)

      # obj.id                = newparam
      # obj.update_record_property({:id => newparam})
      # elsif OPTS[:stone]
      #   obj.stone_type        = newparam
      elsif OPTS[:description]
        obj.description       = newparam
      elsif OPTS[:parent_id]
        obj.parent_id         = newparam
      elsif OPTS[:place_id]
        obj.place_id          = newparam
      elsif OPTS[:box_id]
        obj.box_id            = newparam
      elsif OPTS[:physical_form_id]
        obj.physical_form_id  = newparam
      elsif OPTS[:classification_id]
        obj.classification_id = newparam
      elsif OPTS[:quantity]
        obj.quantity          = newparam
      elsif OPTS[:quantity_unit]
        obj.quantity_unit     = newparam
      elsif OPTS[:global_id]
        # obj.global_id         = newparam
        obj.update_record_property({:global_id => newparam})
      else
        obj.name              = newparam
      end
      obj.save
      p obj.reload if OPTS[:verbose]
    end

    def execute
      if argv.length != 2
        raise "specify id and newparam"
      else
        newparam = argv[1]
        id = argv[0]
      end

      rename(id, newparam)
    end

  end
end
