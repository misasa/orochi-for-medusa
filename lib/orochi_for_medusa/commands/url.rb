require 'orochi_for_medusa/cui'
require 'open3'
module OrochiForMedusa::Commands
	class Url < OrochiForMedusa::Cui
		def option_parser
			opts = OptionParser.new do |opt|
				opt.banner = <<-"EOS".unindent
					NAME
						#{program_name} - Transfer and render a Medusa URL

					SYNOPSIS AND USAGE
						#{program_name} [options] [URL]

					DESCRIPTION
						Transfer and render a Medusa URL.  This will obtain page content
						by `curl' through basic authorization and render it by `w3m', then
						filter out header and footer by itself.  This gets authorization
						information from `~/.orochirc'.

						Essence of this program is shown below.  curl --user user:password
						-s http://database.misasa.okayama-u.ac.jp/stone/stones/19750 | \
						w3m -T text/html -dump

					EXAMPLE
						$ orochi-url http://database.misasa.okayama-u.ac.jp/stone/stones/19745
						yttrium standard solution, 47012-1B, Kanto 1 < 20150521115620-135759 >
						- yttrium standard solution, 47012-1B, Kanto11\me
						- ISEI/main/clean-lab/ICP-MS/tuning solutions/me
						- daughter (1) / analysis / bib / file (1)
						- classification: unknown
						- physical_form: solution
						- quantity (ml): 100.0
						- description: 47012-1B
						- modified at yesterday, 5:47
						$ orochi-url --id 20150521110909-111103
						...

					SEE ALSO
						curl
						w3m
						http://dream.misasa.okayama-u.ac.jp

					IMPLEMENTATION
						Orochi, version 9
						Copyright (C) 2015 Okayama University
						License GPLv3+: GNU GPL version 3 or later

					HISTORY
						May 25, 2015: MY writes the first version

					ARGUMENTS AND OPTIONS
				EOS
				opt.on("-v", "--[no-]verbose", "Run verbosely") {|v| OPTS[:verbose] = v}
				opt.on("-i", "--interactive", "Run interactively") {|v| OPTS[:interactive] = v}
				opt.on("--id", "Guess URL by ID") {|v| OPTS[:id] = v}

			end
			opts
		end


		def transfer_and_render(url)
			user = Base.user
			password = Base.password

			  if OPTS[:id]
			    obj = Record.find_by_id_or_path(url)
			    if obj.kind_of?(Box)
			      klass = "boxes"
			    elsif obj.kind_of?(Stone)
			      klass = "stones"
			    elsif obj.kind_of?(Analysis)
			      klass = "analyses"
			    elsif obj.kind_of?(Place)
			      klass = "places"
			    elsif obj.kind_of?(Bib)
			      klass = "bibs"
			    elsif obj.kind_of?(AttachmentFile)
			      klass = "attachment_files"
			    else
			      raise
			    end
			    url = "http://database.misasa.okayama-u.ac.jp/stone/#{klass}/#{obj.id}"
			  end
			  cmd = "curl --user #{user}:#{password} -s #{url} | \ w3m -T text/html -dump"
			  status = []
			  stdout.puts cmd
			  Open3.popen3(cmd) do |pstdin, pstdout, pstderr|
			    # err = stderr.read
			    # unless err.blank?
			    #   p err
			    # end
			    outputs =  pstdout.read
			    outputs.each_line do |line|
			      stdout.puts line      if line =~ /\<.*\>/
			      stdout.puts line      if line =~ /／me/
			      status.push(line.delete("• ").chomp) if line =~ /• daughter/
			      status.push(line.delete("• ").chomp) if line =~ /• analysis/
			      status.push(line.delete("• ").chomp) if line =~ /• bib/
			      status.push(line.delete("• ").chomp) if line =~ /• file/
			      stdout.puts line.delete("• ")                if line =~ /classification/
			      stdout.puts line.delete("• ")                if line =~ /physical_form/
			      stdout.puts line.delete("• ")                if line =~ /quantity.*\(.*\)/
			      stdout.puts line.delete("• ")                if line =~ /description/
			      stdout.puts line.delete("• ")                if line =~ /modified/
			    end
			    status.shift(3)
			    stdout.puts status.join("/ ")
			  end

		end

		def execute
			if argv.length < 1
			  while answer = stdin.gets do
			    answer.split.each do |id|
			      transfer_and_render(id)
			    end
			  end
			else argv.each do |id|
			    transfer_and_render(id)
			  end
			end

		end	

	end
end