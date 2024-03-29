require 'orochi_for_medusa/cui'
module OrochiForMedusa::Commands
  class Name < OrochiForMedusa::Cui
    def option_parser
      opts = OptionParser.new do |opt|
        opt.banner = <<-"EOS".unindent
          NAME
            #{program_name} - Return name of record specified by Medusa-ID

          SYNOPSIS
            #{program_name} [options] id0 [id1 ...]

          DESCRIPTION
            Access a record in Medusa by ID and return name.  To
            obtain Medusa-ID, use orochi-find.

          SEE ALSO
            orochi-find
            orochi-rename
            http://dream.misasa.okayama-u.ac.jp
            https://github.com/misasa/orochi-for-medusa/blob/master/lib/orochi_for_medusa/commands/name.rb

          IMPLEMENTATION
            Orochi, version 9
            Copyright (C) 2015-2021 Okayama University
            License GPLv3+: GNU GPL version 3 or later

          OPTIONS
        EOS
        opt.on("-v", "--[no-]verbose", "Run verbosely") {|v| OPTS[:verbose] = v}
        opt.on("-l", "--class", "Display class") {|v| OPTS[:class] = v}
        opt.on("-d", "--description", "Display description") {|v| OPTS[:description] = v}
        opt.on("-q", "--quantity", "Display quantity") {|v| OPTS[:quantity] = v}
        opt.on("-p", "--physical_form_id", "Display physical_form_id") {|v| OPTS[:physical_form_id] = v}
        opt.on("--key VALUE", "Specify the attribute to display"){|v| OPTS[:key] = v}
        opt.on("--all", "Display all attributes"){|v| OPTS[:all] = v}
      end
      opts
    end

    def get_and_put(id)
      obj = Record.find(id)
      if OPTS[:all]
        puts obj.attributes
      elsif OPTS[:key]
        v = obj.send(OPTS[:key].to_sym)
        if OPTS[:key] == 'affine_matrix'
          m =v 
          if m && m.size == 9
            array =[m[0..2],m[3..5],m[6..8]]
            v = "[#{array.map{|a| a.join(',')}.join(';')}]"
            #v = "[#{m.join(',')}]"
          else
            v = "[]"
          end
        end
        puts v
      else 
        attributes = [obj.name]
        attributes.push(obj.class)            if OPTS[:class]
        attributes.push(obj.description)      if OPTS[:description]
        attributes.push(obj.quantity)         if OPTS[:quantity]
        attributes.push(obj.physical_form_id) if OPTS[:physical_form_id]
        puts attributes.join(",")
      end
    end
    def execute
      if argv.length < 1
        while answer = stdin.gets do
          answer.split.each do |id|
            get_and_put(id)
          end
        end
      else argv.each do |id|
          get_and_put(id)
        end
      end
    end
  end
end
