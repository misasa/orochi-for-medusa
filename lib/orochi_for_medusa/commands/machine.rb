require 'orochi_for_medusa/cui'
module OrochiForMedusa::Commands
	class Machine < OrochiForMedusa::Cui
		def option_parser
			opts = OptionParser.new do |opt|
				opt.banner = <<-"EOS".unindent
					NAME
						#{program_name} - Start or stop machine session

					SYNOPSIS
						#{program_name} action [options]

					DESCRIPTION
						Start or stop machine session.  This also offers backup interface.
						Action can be `start', `stop', and `sync'.  Machine and
						machine-server should be specified in a configuration file.

						start, stop
						  Start or stop the machin on machine-server to log status

						sync
						  Create backup to remote directory specified in a configuration
						  file.  The action invokes `rsync' as sub-process.

					EXAMPLE OF CONFIGURATION FILE `~/.orochirc'
						machine: 6UHP-70
						uri_machine: database.misasa.okayama-u.ac.jp/machine
						src_path: C:/Users/dream/Desktop/deleteme.d
						dst_path: falcon@itokawa.misasa.okayama-u.ac.jp:/home/falcon/deleteme.d

					SEE ALSO
						http://dream.misasa.okayama-u.ac.jp
						TimeBokan

					IMPLEMENTATION
						Orochi, version 9
						Copyright (C) 2015 Okayama University
						License GPLv3+: GNU GPL version 3 or later

					OPTIONS
				EOS
				opt.on("-v", "--[no-]verbose", "Run verbosely") {|v| OPTS[:verbose] = v}				
				opt.on("-m", "--message", "Add information") {|v| OPTS[:message] = v}
				opt.on("-o", "--open", "Open by web browser") {|v| OPTS[:web] = v}
			end
			opts
		end

		def start_session
			stdout.puts "starting..."
		end

		def execute
			subcommand =  argv.shift.downcase unless argv.empty?
			if subcommand =~ /start/
  				start_session
			elsif subcommand =~ /stop/
  				stop_session
			elsif subcommand =~ /sync/
  				sync_session
			else
				raise "invalid command!"
			end
		end	

	end
end