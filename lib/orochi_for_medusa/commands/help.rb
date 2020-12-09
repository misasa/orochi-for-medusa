require 'orochi_for_medusa/cui'
module OrochiForMedusa::Commands
  class Help < OrochiForMedusa::Cui

    # def option_parser
    #   opts = OptionParser.new do |opt|
    #       opt.banner = <<-"EOS".unindent
    #       NAME
    #           orochi- - Change the orochi working box
    #
    #       SYNOPSIS
    #           #{program_name} [options] box-path
    #
    #       DESCRIPTION
    #           Change the orochi working box.  Set the working box to
    #           environmental variable OROCHI_PWD.
    #
    #       SEE ALSO
    #           orochi-ls
    #           orochi-pwd
    #           http://dream.misasa.okayama-u.ac.jp
    #           https://github.com/misasa/orochi-for-medusa/blob/master/lib/orochi_for_medusa/commands/help.rb
    #
    #       IMPLEMENTATION
    #           Orochi, version 9
    #           Copyright (C) 2015-2020 Okayama University
    #           License GPLv3+: GNU GPL version 3 or later
    #
    #       OPTIONS
    #     EOS
    #     opt.on("-v", "--[no-]verbose", "Run verbosely") {|v| OPTS[:verbose] = v}
    #     opt.on("--id", "Show IDs") {|v| OPTS[:id] = v}
    #   end
    #   opts
    # end

    def execute
      show_help
      # raise "specify path" if argv.size != 1
      # path = argv.shift
      # raise "could not change directory to #{path}" unless Box.chdir(path)
      # stdout.puts OPTS[:id] ? Box.pwd_id : Box.pwd
    end
  end
end
