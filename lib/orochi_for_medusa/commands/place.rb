require 'orochi_for_medusa/cui'
module OrochiForMedusa::Commands
	class Place < OrochiForMedusa::Cui
		def option_parser
			opts = OptionParser.new do |opt|
				opt.banner = <<-"EOS".unindent
					NAME
						#{program_name} - Search Medusa and return latitude and longitude

					SYNOPSIS
						#{program_name} [options] id0 [id1 ...]

					DESCRIPTION
						Search Medusa and return latitude and longitude as tab separated
						format.  Both stone-ID and place-ID are acceptable as argument.

					EXAMPLE
						$ orochi-place 20150425105855-861064 20150425105855-773494 20150425105855-225181
						$ orochi-ls --id 20090819091453801.sanjeewa | orochi-place

					SEE ALSO
						http://dream.misasa.okayama-u.ac.jp

					IMPLEMENTATION
						Orochi, version 9
						Copyright (C) 2015 Okayama University
						License GPLv3+: GNU GPL version 3 or later

					OPTIONS
				EOS
				opt.on("-v", "--[no-]verbose", "Run verbosely") {|v| OPTS[:verbose] = v}				
			end
			opts
		end


		def get_and_put(id)
			obj = Record.find_by_id_or_path(id)
			klass = obj.class.to_s
  			klass.slice!(0,18)  ##  MedusaRestClient::Stone to Stone
  			if obj.kind_of?(MedusaRestClient::Place)
    			stdout.puts "#{klass}\t\t\t#{obj.name}\t#{obj.global_id}\t#{obj.latitude}\t#{obj.longitude}"
  			else
    			stdout.puts "#{klass}\t#{obj.name}\t#{obj.global_id}\t#{obj.place.name}\t#{obj.place.global_id}\t#{obj.place.latitude}\t#{obj.place.longitude}" if obj.place
  			end
		end

		def execute
			stdout.puts "class\tstonename\tstoneID\tplacename\tplaceID\tlatitude\tlongitude"
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