require 'orochi_for_medusa/command_manager'
module OrochiForMedusa
  class Cui
    require 'medusa_rest_client'
    include MedusaRestClient

    attr_accessor :stdin, :stdout, :argv, :opts, :stderr, :cmd_options
    OPTS = {}
    def initialize(argv = ARGV, opts = {})
      @stdout = opts[:stdout] || $stdout
      @stderr = opts[:stderr] || $stderr
      @stdin = opts[:stdin] || $stdin

      @argv = argv
      @program_name = opts[:program_name] || opts[:command_name] || "orochi-command"
      clear_options
      @opts = option_parser
      @cmd_options = {}
    end

    def program_name
      @program_name
    end

    def option_parser
      opts = OptionParser.new do |opt|
          opt.banner = <<-"EOS".unindent
          NAME
              orochi - A comprehensive utility for Medusa

          SYNOPSIS
              orochi-command [options]

          COMMANDS
            #{OrochiForMedusa::CommandManager.orochi_commands.join(", ")}

          SEE ALSO
            orochi-command --help

          IMPLEMENTATION
            Orochi, version 9
            Copyright (C) 2015-2020 Okayama University
            License GPLv3+: GNU GPL version 3 or later

          OPTIONS
        EOS
        opt.on("-v", "--[no-]verbose", "Run verbosely") {|v| options[:verbose] = v}
      end
      opts      
    end

    def options
      OPTS
    end

    def clear_options
      OPTS.clear
    end

    def parse_options
      opts.parse!(argv)     
    end

    def show_help
      stdout.puts opts
    end

    def show_help_and_exit
      show_help
      exit
    end

    def system_execute(cmd)
      system(cmd)
    end

    def execute
      #overwirteme
    end

    def self.platform
      RUBY_PLATFORM.downcase
    end

    def platform
      self.class.platform
    end

    def run
      Base.init
      parse_options
      if options[:verbose]
          ActiveResource::Base.logger = Logger.new($stderr)
      end
      begin
        execute
      rescue => e
        stderr.puts "error: #{e}"
        exit(false)
      end
    end
  end
end