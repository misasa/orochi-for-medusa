require 'orochi_for_medusa/cui'
module OrochiForMedusa::Commands
  class Upload < OrochiForMedusa::Cui
    def option_parser
      opts = OptionParser.new do |opt|
        opt.banner = <<-"EOS".unindent
          NAME
            #{program_name} - Upload any files to service by Medusa

          SYNOPSIS
            #{program_name} [options] file0 [file1 ...]

          DESCRIPTION
            Upload image and casteml files to service by Medusa.
            For image, png and jpg files are accepted.  Note that casteml
            files are treated in special way.  For files of `*.pml',
            an external program `casteml upload' is called.  For
            stone registration, call `orochi-mkstone' instead of this
            program.

            Note that `casteml upload' does not take stone-ID as an
            option.  This is because stone-ID to be correlated with,
            should be specified in pmlfile.

            When this program finds imageometry file
            `my-spots-picture.geo' (Affine matrix of xy-on-image to vs
            space), it also uploads it.  Use `vs_attach_image.m' or
            `vs-attach-image --dry-run' to create the imageometry file.
            An example of the imageometry file is shown below.

            $ cat my-spots-picture.geo
            affine_xy2vs:
            - [1.2, 0.0,  4.2]
            - [0.0, 1.2, -1.3]
            - [  0,   0,  1.0]

            To upload an image onto a layer of a surface, specify the surface
            and the layer with `--layer' and `--surface_id' option.
          
          EXAMPLE
            $ ls
            my-spots-picture.jpg my-spots-picture.geo
            $ orochi-upload my-spots-picture.jpg --surface_id=20181122134024-911579
            $ orochi-upload my-spots-picture.jpg --surface_id=20181122134024-911579 --layer=my-layer
            $ orochi-upload my-spots-picture.jpg --surface_id=20181122134024-911579 --layer=top

          SEE ALSO
            http://dream.misasa.okayama-u.ac.jp
            casteml upload
            orochi-mkstone
            vs_attach_image.m
            https://github.com/misasa/orochi-for-medusa/blob/master/lib/orochi_for_medusa/commands/upload.rb

          HISTORY
            February 8, 2019: Upload also imageometry file if it exists
            January 20, 2020: Add options to specify surface and layer to upload image
        
          IMPLEMENTATION
            Orochi, version 9
            Copyright (C) 2015-2019, Okayama University
            License GPLv3+: GNU GPL version 3 or later

          OPTIONS
        EOS
        opt.on("-v", "--[no-]verbose", "Run verbosely") {|v| OPTS[:verbose] = v}
        opt.on("--surface_id=VALUE", "Link to a surface") {|v| OPTS[:surface_id] = v}
        opt.on("--layer=LAYER_NAME", "Link to a layer (only valid with `--surface_id' option)") {|v| OPTS[:layer] = v}
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
      elsif [".jpg", ".png", ".JPG", ".PNG", ".jpeg", ".JPEG"].include?(ext.downcase)
        attach = AttachmentFile.upload(arg)
        p attach
      else
        puts "unsupported file extension"
      end
    end

    def upload_to_surface(f, surface_id)
      ActiveResource::Base.logger = Logger.new(STDOUT) if OPTS[:verbose];
      #"include MedusaRestClient; ActiveResource::Base.logger = Logger.new(STDOUT); f = %w($(MASTER_IMG) $(TARGET_IMG)); s = Record.find('$(SURFACE)'); i=s.images.map{|t| t.image }; n = i.map{|t| t.name.sub('_','x')};f.each{|t| n.include?(t) ? (AttachmentFile.find(i[n.index(t)].id).update_file(t)): (s.upload_image(:file => t))}" 
      s = Record.find(surface_id)
      i=s.images.map{|t| t.image }
      #n = i.map{|t| t.name.sub('_','x')}
      #f.each{|t| n.include?(t) ? (AttachmentFile.find(i[n.index(t)].id).update_file(t)): (s.upload_image(:file => t))} 
      n = i.map{|t| t.name }
      f.each do |t|
        tt = File.basename(t).gsub('x','_').gsub(' ','_')
        if n.include?(tt)
          AttachmentFile.find(i[n.index(tt)].id).update_file(t)
        else
          af = s.upload_image(:file => t)
        end
      end
      if OPTS[:layer]
        layer_name = OPTS[:layer]
        s = Record.find(surface_id)
        if layer_name.downcase == 'top'
          layer_id = nil
        else
          layer_names = s.layers.map{|id,name| name }
          idx = layer_names.index(layer_name)
          raise "layer `#{layer_name}' does not exist in surface `#{s.name}'." if idx.nil?
          layer_id = s.layers[idx][0]
        end
        s_images = s.images
        i = s_images.map{|t| t.image }
        n = i.map{|t| t.name }
        f.each do |t|
          tt = File.basename(t).gsub('x','_').gsub(' ','_')
          if n.include?(tt)
            s_image = s_images[n.index(tt)]
            s_image.surface_layer_id = layer_id
            s_image.save
          end
        end
      end
    end
  end
end
