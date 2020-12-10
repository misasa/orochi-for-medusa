require 'orochi_for_medusa/cui'
module OrochiForMedusa::Commands
  class Upload < OrochiForMedusa::Cui
    def option_parser
      opts = OptionParser.new do |opt|
        opt.banner = <<-"EOS".unindent
          NAME
            #{program_name} - Upload any files to Medusa 9

          SYNOPSIS
            #{program_name} [options] file0 [file1 ...]

          DESCRIPTION
            Upload any files to Medusa.  Note that casteml files are treated
            in special way.  For files of `*.pml', an external program
            `casteml upload' is invoked.  For stone registration, call
            `orochi-mkstone' instead of this program.

            Note that `casteml upload' does not take stone-ID as an option.
                        This is because stone-ID to be correlated with, should be specified
                        in pmlfile.

            When this program finds imageometry file file
            `my-spots-picture.geo' (Affine matrix of xy-on-image to vs
            space), it also uploads it.  Use `vs_attach_image.m' to
            create the imageometry file.  An example of the
            imageometry file is shown below.

            $ cat my-spots-picture.geo
            affine_xy2vs:
            - [1.2, 0.0,  4.2]
            - [0.0, 1.2, -1.3]
            - [  0,   0,  1.0]

          SEE ALSO
            http://dream.misasa.okayama-u.ac.jp
            casteml upload
            orochi-mkstone
            vs_attach_image.m

          HISTORY
            February 8, 2019: Upload also imageometry file if it exists

          IMPLEMENTATION
            Orochi, version 9
            Copyright (C) 2015-2019, Okayama University
            License GPLv3+: GNU GPL version 3 or later

          OPTIONS
        EOS
        opt.on("-v", "--[no-]verbose", "Run verbosely") {|v| OPTS[:verbose] = v}
        opt.on("-j", "--save-json", "Save record as json") {|v| OPTS[:save_json] = v}
      end
      opts
    end

    def execute
      if argv.length < 1
        while answer = stdin.gets do
          answer.split.each do |file|
            upload(file)
          end
        end
      else argv.each do |file|
          upload(file)
        end
      end
    end

    def upload(arg)
      ext = File.extname(arg)
      if ext.downcase == ".jpg"
        img = AttachmentFile.upload(arg)
        if img && OPTS[:save_json]
          json_path = File.join(File.dirname(arg), File.basename(arg,".*") + '.json')
          STDERR.puts("writing |#{File.expand_path(json_path)}|")
          File.write json_path, img.to_json
        else
          puts img.to_json
        end
      elsif ext.downcase == ".pml"
        cmd = "casteml upload #{arg}"
        puts cmd
        system_execute(cmd)
      else
        puts "unsupported file extension"
      end
    end

  end
end
