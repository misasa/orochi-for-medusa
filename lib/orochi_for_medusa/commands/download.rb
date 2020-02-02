require 'orochi_for_medusa/cui'
require 'open3'
module OrochiForMedusa::Commands
  class Download < OrochiForMedusa::Cui
    def option_parser
      opts = OptionParser.new do |opt|
        opt.banner = <<-"EOS".unindent
          NAME
            #{program_name} - Download full datasets for poly families

          SYNOPSIS
            #{program_name} [options] id0 [id1 ...]

          DESCRIPTION
            Download full datasets for poly families.  The downloaded datasets
            are organized by each family in a name of their godfather.  Feed
            stone, box, or bib that return a stone in a family by orochi-ls.
            This program calls external programs sequentially as shown below.

            - orochi-ls --id
            - orochi-uniq
            - casteml download -R
            - casteml convert --smash -f pml
            - sed -e 's/average/godfather/g'
            - casteml join

          SEE ALSO
            orochi-ls
            orochi-uniq
            casteml download
            casteml convert
            casteml join
            http://dream.misasa.okayama-u.ac.jp
            https://github.com/misasa/orochi-for-medusa/blob/master/lib/orochi_for_medusa/commands/download.rb

          IMPLEMENTATION
            Orochi, version 9
            Copyright (C) 2015-2020 Okayama University
            License GPLv3+: GNU GPL version 3 or later

          OPTIONS
        EOS
        opt.on("-v", "--[no-]verbose", "Run verbosely") {|v| OPTS[:verbose] = v}
        opt.on("-r", "--recursive", "Run recursively") {|v| OPTS[:recursive] = v}
        opt.on("-p", "--pml", "export as pmlfile") {|v| OPTS[:pml] = v}
        opt.on('-o outfile','-f outfile') {|v| OPTS[:o] = v}
      end
      opts
    end

    def execute
      ids = argv.clone
      if ids.join.blank?
        while answer = stdin.gets do
          answer.split.each do |arg|
            get_and_put(arg)
          end
        end
      else 
        ids.each do |arg|
          get_and_put(arg)
        end
      end
    end

    def get_and_put(id)
      if OPTS[:recursive]
        cmd = "orochi-ls --id -r #{id} | orochi-uniq"
      else
        cmd = "orochi-ls --id #{id} | orochi-uniq"
      end
      if File.exist?("./deleteme.#{id}.d")
        print "mkdir: deleteme.#{id}.d: File exists.  Move the directory.\n"
        raise
      else
        cmd1 = "mkdir deleteme.#{id}.d"
        p cmd1 if OPTS[:verbose]
        system(cmd1)
      end
      p cmd if OPTS[:verbose]
      Open3.popen3(cmd) do |stdin, stdout, stderr|
        ids =  stdout.read
        puts ids if OPTS[:verbose]
        ids.each_line do |family_id|
          puts family_id if OPTS[:verbose] 
          cmd21 = "orochi-pwd --family --top #{family_id}"
          p cmd21 if OPTS[:verbose]
          Open3.popen3(cmd21) do |stdin, stdout, stderr|
            @godfather =  stdout.read.chomp
          end
          temp = Tempfile.open(["tempml", ".pml"])
          cmd22 = "casteml download -R #{family_id.chomp} > #{temp.path}"
          p cmd22 if OPTS[:verbose]
          system(cmd22)
          cmd3 = "casteml convert -f pml --smash #{temp.path} | sed -e 's/average/#{@godfather}/g' > deleteme.#{id}.d/#{@godfather}.pml"
          p cmd3 if OPTS[:verbose]
          system(cmd3)
        end
        if OPTS[:o]
          ext = File.extname(OPTS[:o])
          outfile = File.basename(OPTS[:o], ext)
        else
          outfile = "Sheet1"
        end
        cmd32 = "casteml join deleteme.#{id}.d/*.pml > #{outfile}.pml"
        p cmd32 if OPTS[:verbose]
        system(cmd32)
        cmd4 = "casteml convert -f csv #{outfile}.pml > #{outfile}.csv"
        p cmd4 if OPTS[:verbose]
        system(cmd4)
        unless OPTS[:pml]
          cmd5 = "rm -rf deleteme.#{id}.d/"
          p cmd5 if OPTS[:verbose]
          system(cmd5)
        end
      end
    end
  end
end
