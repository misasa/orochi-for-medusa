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
            Upload files to service run by Medusa.  Note that casteml
            files are treated in special way.  For files of `*.pml',
            an external program `casteml upload' is called.  For
            stone registration, call `orochi-mkstone' instead of this
            program.

            Note that `casteml upload' does not take stone-ID as an
            option.  This is because stone-ID to be correlated with,
            should be specified in pmlfile.

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
        opt.on("--surface_id=VALUE", "Link to surface") {|v| OPTS[:surface_id] = v}
        #opt.parse!(ARGV)
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
      elsif OPTS[:surface_id]
          upload_to_surface(argv, OPTS[:surface_id])       
      else argv.each do |file|
          upload(file)
        end
      end
    end

    def upload(arg)
      ext = File.extname(arg)
      if ext.downcase == ".pml"
        cmd = "casteml upload #{arg}"
        puts cmd
        system_execute(cmd)
      else
         attach = AttachmentFile.upload(arg)
         p attach
      end
    end

    def upload_surface(f, surface_id)
      ActiveResource::Base.logger = Logger.new(STDOUT) if OPTS[:verbose];
      #"include MedusaRestClient; ActiveResource::Base.logger = Logger.new(STDOUT); f = %w($(MASTER_IMG) $(TARGET_IMG)); s = Record.find('$(SURFACE)'); i=s.images.map{|t| t.image }; n = i.map{|t| t.name.sub('_','x')};f.each{|t| n.include?(t) ? (AttachmentFile.find(i[n.index(t)].id).update_file(t)): (s.upload_image(:file => t))}" 
      s = Record.find(surface_id);i=s.images.map{|t| t.image };n = i.map{|t| t.name.sub('_','x')};f.each{|t| n.include?(t) ? (AttachmentFile.find(i[n.index(t)].id).update_file(t)): (s.upload_image(:file => t))} 
    end
  end
end
