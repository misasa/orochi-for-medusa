require 'orochi_for_medusa/cui'
module OrochiForMedusa::Commands
	class Info < OrochiForMedusa::Cui
		def option_parser
			opts = OptionParser.new do |opt|
				opt.banner = <<-"EOS".unindent
          NAME
            #{program_name} - Open record by w3m

          SYNOPSIS
            #{program_name} [options] id0 [id1 ...]

          DESCRIPTION
            Open record by w3m.

          SEE ALSO
            orochi-open
            http://dream.misasa.okayama-u.ac.jp

					IMPLEMENTATION
						Orochi, version 9
						Copyright (C) 2015 Okayama University	
						License GPLv3+: GNU GPL version 3 or later

					OPTIONS
				EOS
  				opt.on("-v", "--[no-]verbose", "Run verbosely") {|v| OPTS[:verbose] = v}
          opt.on("-i", "--interactive", "Run interactively") {|v| OPTS[:interactive] = v}
			end
			opts
		end


    def w3m(id)
      url = "http://dream.misasa.okayama-u.ac.jp/?q=#{id}"
      system("w3m #{url}")
    end

		def execute
      if argv.length < 1
        while answer = stdin.gets do
          answer.split.each do |id|
            w3m(id)
          end
        end
      else 
        argv.each do |id|
          w3m(id)
        end
      end

		end



	end
end