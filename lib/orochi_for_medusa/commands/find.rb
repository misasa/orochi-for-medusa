require 'orochi_for_medusa/cui'
module OrochiForMedusa::Commands
	class Find < OrochiForMedusa::Cui
		def option_parser
			opts = OptionParser.new do |opt|
				opt.banner = <<-"EOS".unindent
					NAME
						#{File.basename($0, '.*')} - Search Medusa by keyword

					SYNOPSIS
						#{File.basename($0, '.*')} [options] keyword

					DESCRIPTION
						Search Medusa by keyword and return Medusa-ID.  To obtain name of
						Medusa-ID, use orochi-name.

					EXAMPLE
						DOS> orochi-find maagnetite
						DOS> orochi-find maagnetite | orochi-name

					SEE ALSO
						orochi-name
						http://dream.misasa.okayama-u.ac.jp

					IMPLEMENTATION
						Orochi, version 9
						Copyright (C) 2015-2016 Okayama University
						License GPLv3+: GNU GPL version 3 or later

					OPTIONS
				EOS
				opt.on("-v", "--[no-]verbose", "Run verbosely") {|v| OPTS[:verbose] = v}				
 				opt.on("--name", "Display name") {|v| OPTS[:name] = v}
                opt.on("--eq", "Exact match") {|v| OPTS[:eq] = v}
			end
			opts
		end

		def execute
			ids = argv.clone
			
			if argv.length < 1
  				while answer = stdin.gets do
    				find(answer.chomp)
  				end
			elsif argv.length > 1
				puts opts
			else
				find(argv[0])
			end
		end	


		def find(keyword)
		  page = 1
		  while true
            if OPTS[:eq]
	          objs = Record.find(:all, :params =>{:q => {:name_eq => keyword}, :page => page})
            else
		      objs = Record.find(:all, :params =>{:q => {:name_or_global_id_cont => keyword}, :page => page})
            end
		    break if objs.size == 0
		    objs.each do |obj|
		      if OPTS[:name]
		        stdout.puts obj.name
		      else
		        stdout.puts obj.global_id
		      end
		    end
		    page += 1
		  end
		end

	end
end
