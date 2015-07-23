module OrochiForMedusa
	class Cui
		require 'medusa_rest_client'
		include MedusaRestClient

		attr_accessor :stdout, :argv, :opts, :stderr
		OPTS = {}		
		def initialize(argv = ARGV, opts = {})
			@stdout = opts[:stdout] || $stdout
			@stderr = opts[:stderr] || $stderr
			@argv = argv
			@program_name = opts[:program_name] || "orochi-command"
			clear_options
			@opts = option_parser
		end

		def program_name
			@program_name
		end

		def option_parser
			opts = OptionParser.new do |opt|
  				opt.banner = <<-"EOS".unindent
					NAME
					    #{program_name} - Change the orochi working box

					SYNOPSIS
					    #{program_name} [options] box-path

					DESCRIPTION

					SEE ALSO

					IMPLEMENTATION
					    Orochi, version 9
					   	Copyright (C) 2015 Okayama University
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

		def execute
			#overwirteme
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