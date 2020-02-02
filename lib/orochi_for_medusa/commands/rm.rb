require 'orochi_for_medusa/cui'
module OrochiForMedusa::Commands
  class Rm < OrochiForMedusa::Cui
    def option_parser
      opts = OptionParser.new do |opt|
        opt.banner = <<-"EOS".unindent
          NAME
            #{program_name} - Remove a specified record

          SYNOPSIS
            #{program_name} [options] id0 [id1 ...]

          DESCRIPTION
            Remove a specified record on Medusa

          SEE ALSO
            orochi-find
            http://dream.misasa.okayama-u.ac.jp
            https://github.com/misasa/orochi-for-medusa/blob/master/lib/orochi_for_medusa/commands/rm.rb

          IMPLEMENTATION
            Orochi, version 9
            Copyright (C) 2015-2020 Okayama University
            License GPLv3+: GNU GPL version 3 or later

          OPTIONS
        EOS
        opt.on("-v", "--[no-]verbose", "Run verbosely") {|v| OPTS[:verbose] = v}
        opt.on("-f", "--force", "No prompt on deletion") {|v| OPTS[:force] = v}

      end
      opts
    end

    def execute
      if argv.length < 1
        while answer = stdin.gets do
          answer.split.each do |id|
            get_and_rm(id)
          end
        end
      else argv.each do |id|
          get_and_rm(id)
        end
      end     
    end 

    def get_and_rm(arg)
      # id.each do |arg|
      obj = Record.find_by_id_or_path(arg)
      if OPTS[:force]
      else
        stdout.print "Are you sure you want to delete #{obj.name}? [Y/n/!] "
        answer = (stdin.gets)[0].downcase
        if answer == "y" or answer == "\n"
          stdout.puts "You chose yes to this record" if OPTS[:verbose]
        elsif answer == "!"
          stdout.puts "You chose yes to all" if OPTS[:verbose]
          OPTS[:force] = true
        else
          stdout.puts "You chose no for this record" if OPTS[:verbose]
          return
          # next
        end
      end
      obj.destroy
      # end
    end


  end
end
