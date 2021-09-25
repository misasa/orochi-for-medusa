require 'orochi_for_medusa/cui'
module OrochiForMedusa::Commands
  class Mkstone < OrochiForMedusa::Cui
    def option_parser
      opts = OptionParser.new do |opt|
        opt.banner = <<-"EOS".unindent
        NAME
            #{program_name} - Create a stone (or box) and print barcode

        SYNOPSIS
            #{program_name} stonename [options]

        DESCRIPTION
            Create a stone (or box), if it does not already exist.  Then print barcode of the record.

        SEE ALSO
            orochi-upload
            http://dream.misasa.okayama-u.ac.jp
            https://github.com/misasa/orochi-for-medusa/blob/master/lib/orochi_for_medusa/commands/mkstone.rb

          IMPLEMENTATION
            Orochi, version 9
            Copyright (C) 2015-2021 Okayama University
            License GPLv3+: GNU GPL version 3 or later

          OPTIONS
        EOS
        opt.on("-v", "--[no-]verbose", "Run verbosely") {|v| OPTS[:verbose] = v}

        opt.on('-o outfile','-f outfile') {|v| OPTS[:o] = v}
        opt.on("-T image", "--upload-file image", "Run upload_file") {|v| OPTS[:upload_file] = v}
        opt.on("-x", "--box", "Make a box") {|v| OPTS[:mkbox] = v}
        opt.on("--label", "NOT print barcode") {|v| OPTS[:label] = v}
      end
      opts
    end

    def execute
      raise "specify name" if argv.length != 1
      stonename = argv[0]
      mkstone(stonename)
    end

    def mkstone(stonename)
      if OPTS[:mkbox]
        obj = Box.new
      else
        obj = Specimen.new
      end
      obj.name = "#{stonename}"
      obj.save
      if OPTS[:upload_file]
        obj.upload_file(:file => File.expand_path(OPTS[:upload_file]))
      end
      puts obj.global_id

      unless OPTS[:label]
        cmd = "tepra print #{obj.global_id},#{obj.name}"
        print "--> RUBY_PLATFORM |#{RUBY_PLATFORM}|\n" if OPTS[:verbose]
        # STDERR.print "--> RUBY_PLATFORM |#{RUBY_PLATFORM}|\n"
        unless RUBY_PLATFORM.downcase =~ /darwin/
          # print "--> cmd |#{cmd}|\n" if OPTS[:verbose]
          STDERR.print "--> cmd |#{cmd}|\n"
          system_execute(cmd)
        end
      end
    end
  end
end
