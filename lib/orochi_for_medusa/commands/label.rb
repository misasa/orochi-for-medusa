require 'orochi_for_medusa/cui'
module OrochiForMedusa::Commands
	class Label < OrochiForMedusa::Cui
		def option_parser
			opts = OptionParser.new do |opt|
				opt.banner = <<-"EOS".unindent
          NAME
            #{program_name} - Create barcode label of Medusa-ID and stone-name

          SYNOPSIS
            #{program_name} [options] Medusa-ID

          DESCRIPTION
            Create barcode label of Medusa-ID and stone name.  On failure to
            obtain stone-name from Medusa, create label only with Medusa-ID.

            As of November 11, 2014, label is created by King Jim's Tepra
            through software `SPC 10'.  Setup this computer and make sure you
            can print something from `SPC 10'.

            Then setup OROCHI-TEPRA environment.  Install Ruby gem `tepra' by
            Okayama University as shown below.
            $ gem source -a http://devel.misasa.okayama-u.ac.jp/gems/
            $ gem install tepra

            A program named `tepra' will be installed on somewhere
            appropriate.  Check where it is by `which tepra'.  Issue following
            to have test label.
            $ tepra print "20110119154409-142-363,Heaven"

            Failure is because the gem cannot find printer.  This often
            happens when printer is connected on Wi-Fi instead of USB.
            Identify name of the printer on `SPC 10' such as `KING JIM
            SR5900P-NW'.  Put it to a configuration file `~/.teprarc'.  A line
            should look like below.
            :printer: KING JIM SR5900P-NW

          SEE ALSO
            http://dream.misasa.okayama-u.ac.jp
            gem tepra
            gem medusa_rest_client
            tepra-duplicate

					IMPLEMENTATION
						Orochi, version 9
						Copyright (C) 2015 Okayama University	
						License GPLv3+: GNU GPL version 3 or later

					OPTIONS
				EOS
  				opt.on("-v", "--[no-]verbose", "Run verbosely") {|v| OPTS[:verbose] = v}
          opt.on("-c", "--open", "Not open web browser") {|v| OPTS[:open] = v}

			end
			opts
		end



		def execute
      if argv.length < 1
        while answer = stdin.gets do
          answer.split.each do |id|
            find_and_print(id)
          end
        end
      else 
        argv.each do |id|
          find_and_print(id)
        end
      end

		end

    def find_and_print(global_id)
      if global_id =~ /query=(.*)/
        global_id  = $1
      end
      begin  obj = Record.find_by_id_or_path(global_id)
        puts obj.name
        cmd = "tepra print '#{obj.global_id},#{obj.name}'"
      rescue
        cmd = "tepra print '#{global_id},#{global_id}'"
      end
      p cmd
      Open3.popen3(cmd) do |stdin, stdout, stderr|
        err = stderr.read
        unless err.blank?
          p err
          puts global_id
        end
        # begin
        #   system(cmd)
        # rescue
        #   puts "tepra error"
        #   puts obj.global_id
        # end
      end
      unless  OPTS[:open]
        # if obj.kind_of?(Box)
        #   klass = "boxes"
        # elsif obj.kind_of?(Stone)
        #   klass = "stones"
        # elsif obj.kind_of?(Analysis)
        #   klass = "analyses"
        # elsif obj.kind_of?(Place)
        #   klass = "places"
        # elsif obj.kind_of?(Bib)
        #   klass = "bibs"
        # elsif obj.kind_of?(AttachmentFile)
        #   klass = "attachment_files"
        # else
        #   raise
        # end
        # url = "http://database.misasa.okayama-u.ac.jp/stone/#{klass}/#{obj.id}"
        url = "http://dream.misasa.okayama-u.ac.jp/?q=#{obj.global_id}"
        p RUBY_PLATFORM
        if RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|bccwin/
          system("start #{url}")
        elsif RUBY_PLATFORM.downcase =~ /cygwin/
          system("cygstart #{url}")
        elsif RUBY_PLATFORM.downcase =~ /darwin/ 
          system("open #{url}")
        else
          raise
        end
      end
    end



	end
end