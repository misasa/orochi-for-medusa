require 'orochi_for_medusa/cui'
module OrochiForMedusa::Commands
  class Upload < OrochiForMedusa::Cui
    def option_parser
      OPTS[:force_create_layer] = true
      opts = OptionParser.new do |opt|
        opt.banner = <<-"EOS".unindent
          NAME
            #{program_name} - Upload image and casteml files to service by Medusa

          SYNOPSIS
            #{program_name} [options] file0 [file1 ...]

          DESCRIPTION
            Upload image and casteml files to service by Medusa.
            Image format of PNG and JPG but BMP are supported.  Note
            that casteml files are treated in special way.  For files
            of `*.pml', an external program `casteml upload' is
            called.  For stone registration, call `orochi-mkstone'
            instead of this program.

            Note that `casteml upload' does not take stone-ID as an
            option.  This is because stone-ID to be correlated with,
            should be specified in pmlfile.

            When this program finds imageometry file `my-picture.geo'
            (Affine matrix of xy-on-image to vs space), it also
            uploads it and update Affine matrix of the image stored on
            a service provided by Medusa.  When this program does not
            find the imageometry, Affine matrix of the image stored on
            a service provided by Medusa remains intact.  Use
            `vs_attach_image.m' or `vs-attach-image --dry-run' to
            create the imageometry file.  An example of the
            imageometry file is shown below.

            $ cat my-picture.geo
            affine_xy2vs:
            - [1.2, 0.0,  4.2]
            - [0.0, 1.2, -1.3]
            - [  0,   0,  1.0]

            To upload an image with preferred name, specify the
            filename by `--store-as' options.  To upload images with
            preffered prefix, specify the prefix by
            `--store-with-prefix' options.  To upload images with
            preffered suffix, specify the suffix by
            `--store-with-suffix' options.  To upload an image onto a
            layer of a surface, specify the surface and the layer by
            `--surface_id' and `--layer' options.

          EXAMPLE
            $ ls
            my-picture.jpg my-picture.geo
            $ #{program_name} my-picture.jpg --surface_id=20181122134024-911579
            # upload with preffered filename (for single file upload)
            $ #{program_name} my-picture.jpg --surface_id=20181122134024-911579 --store-as=my-preffered-filename.jpg
            # upload with preffered prefix (for mulitple files upload)            
            $ #{program_name} my-picture.jpg --surface_id=20181122134024-911579 --store-with-prefix=preffered-prefix@
            # upload with preffered suffix (for multiple files upload) my-picture@preffered-suffix.jpg
            $ #{program_name} my-picture.jpg --surface_id=20181122134024-911579 --store-with-suffix=@preffered-suffix
            # link to the layer `my-layer'
            $ #{program_name} my-picture.jpg --surface_id=20181122134024-911579 --layer=my-layer
            # link to the layer `my-layer' and refresh tile
            $ #{program_name} my-picture.jpg --surface_id=20181122134024-911579 --layer=my-layer --refresh-tile
            # unlink from the present layer 
            $ #{program_name} my-picture.jpg --surface_id=20181122134024-911579 --layer=top
            # upload with specified imageometryfile
            $ ls /tmp
            28Si-int.geo
            $ #{program_name} my-picture.jpg --surface_id=20181122134024-911579 --geo=/tmp/28Si-int.geo

          SEE ALSO
            casteml upload
            orochi-mkstone
            vs_attach_image.m
            http://dream.misasa.okayama-u.ac.jp
            https://github.com/misasa/orochi-for-medusa/blob/master/lib/orochi_for_medusa/commands/upload.rb

          HISTORY
          March 12, 2020: Add options to specify preffered filename, prefix, and suffix
          January 20, 2020: Add options to specify surface and layer to upload image
          February 8, 2019: Upload also imageometry file if it exists
            
          IMPLEMENTATION
            Orochi, version 9
            Copyright (C) 2015-2021 Okayama University
            License GPLv3+: GNU GPL version 3 or later

          OPTIONS
        EOS
        opt.on("-v", "--[no-]verbose", "Run verbosely") {|v| OPTS[:verbose] = v}
        opt.on("--geo=IMAGEOMETRYFILE", "Specify imageometryfile") {|v| OPTS[:geo_path] = v}
        opt.on("--surface_id=VALUE", "Link to a surface") {|v| OPTS[:surface_id] = v}
        opt.on("--layer=LAYER_NAME", "Link to a layer (only valid with `--surface_id' option)") {|v| OPTS[:layer] = v}
        opt.on("--[no-]force-create-layer", "Force create layer (default true and only valid with `--surface_id' and `--layer' option)") {|v| OPTS[:force_create_layer] = v}
        opt.on("--refresh-tile", "Refresh tiles (only valid with `--surface_id' and `--layer' option)") {|v| OPTS[:refresh_tile] = v}
        opt.on("--store-as=STORE_AS_NAME", "Store as a file with specified name") {|v| OPTS[:filename] = v}
        opt.on("--store-with-prefix=STORE_WITH_PREFIX", "Store as a file with specified prefix") {|v| OPTS[:prefix] = v}
        opt.on("--store-with-suffix=STORE_WITH_SUFFIX", "Store as a file with specified suffix") {|v| OPTS[:suffix] = v}
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
      else 
        argv.each do |file|
          upload(file)
        end
      end
    end

    def build_opts_for_image(path)
      basename = File.basename(path)
      opts = {:filename => basename}
      opts = opts.merge({:filename => OPTS[:filename]}) if OPTS[:filename]
      opts = opts.merge({:geo_path => OPTS[:geo_path]}) if OPTS[:geo_path]
      if OPTS[:prefix] || OPTS[:suffix]
        basename = File.basename(opts[:filename], ".*")
        extname = File.extname(opts[:filename])
        filename = basename
        filename = OPTS[:prefix] + filename if OPTS[:prefix]
        filename = filename + OPTS[:suffix] if OPTS[:suffix]
        filename = filename + extname
        opts[:filename] = filename
      end
      opts
    end

    def upload(arg)
      dirname = File.dirname(arg)
      basename = File.basename(arg, ".*")
      ext = File.extname(arg)
      json_path = File.join(dirname, basename + ".json")
      if ext.downcase == ".pml"
        cmd = "casteml upload #{arg}"
        puts cmd
        system_execute(cmd)
      elsif [".jpg", ".png", ".JPG", ".PNG", ".jpeg", ".JPEG"].include?(ext.downcase)
        opts = build_opts_for_image(arg)
        attach = AttachmentFile.upload(arg, opts)
        show_id_and_dump_file(attach.global_id, json_path)
        #p attach
      else
        puts "unsupported file extension"
      end
    end

    def show_id_and_dump_file(id, path)
      puts "#{id}"
      puts "writing |#{path}|..." if OPTS[:verbose];
      record = Record.find(id)
      File.write(path, record.to_json)
    end

    def upload_to_surface(f, surface_id)
      ActiveResource::Base.logger = Logger.new(STDOUT) if OPTS[:verbose];
      # "include MedusaRestClient; ActiveResource::Base.logger = Logger.new(STDOUT); f = %w($(MASTER_IMG) $(TARGET_IMG)); s = Record.find('$(SURFACE)'); i=s.images.map{|t| t.image }; n = i.map{|t| t.name.sub('_','x')};f.each{|t| n.include?(t) ? (AttachmentFile.find(i[n.index(t)].id).update_file(t)): (s.upload_image(:file => t))}"
      s = Record.find(surface_id)
      if OPTS[:layer]
        layer_name = OPTS[:layer]
        if layer_name.downcase != 'top'
          layer_names = s.attributes["layers"].map{|id, name| name }
          unless layer_names.any?(layer_name)
            if OPTS[:force_create_layer]
              priority = 0
              _priorities = s.attributes["layers_priority"].map{|prio, name| prio}
              priority = _priorities.max + 1 if _priorities.size > 0
              p "creating layer #{layer_name}..." if OPTS[:verbose]
              s.create_layer({name: layer_name, surface_id: s.id, opacity: 100, priority: priority})
              s = Record.find(surface_id)
            else
              raise "layer `#{layer_name}' does not exist in surface `#{s.name}'."
            end
          end
        end
      end
      i=s.images.map{|t| t.image }
      # n = i.map{|t| t.name.sub('_','x')}
      # f.each{|t| n.include?(t) ? (AttachmentFile.find(i[n.index(t)].id).update_file(t)): (s.upload_image(:file => t))}
      n = i.map{|t| t.name }
      if OPTS[:layer]
        layer_name = OPTS[:layer]
        if layer_name.downcase == 'top'
          layer_id = nil
        else
          #layer = s.create_or_find_layer_by_name(layer_name)
          layer_names = s.attributes["layers"].map{|id,name| name }
          idx = layer_names.index(layer_name)
          raise "layer `#{layer_name}' does not exist in surface `#{s.name}'." if idx.nil?
          layer_id = s.attributes["layers"][idx][0]
        end
      end
      f.each do |t|
        dirname = File.dirname(t)
        basename = File.basename(t, ".*")
        json_path = File.join(dirname, basename + ".json")
        opts = build_opts_for_image(t)
        tt = opts[:filename].gsub(' ','_')
        if n.include?(tt)
          af = AttachmentFile.find(i[n.index(tt)].id)
          af.filename = opts[:filename]
          af.update_file(t, opts)
          gid = af.global_id
        else
          af = s.upload_image(opts.merge({:file => t}))
          af = af.reload
          gid = af.global_id
        end
        show_id_and_dump_file(gid, json_path) if gid
      end
      if OPTS[:layer]
        s_images = s.images
        i = s_images.map{|t| t.image }
        n = i.map{|t| t.name }
        f.each do |t|
          opts = build_opts_for_image(t)
          tt = opts[:filename].gsub(' ','_')
          if n.include?(tt)
            s_image = s_images[n.index(tt)]
            s_image.surface_layer_id = layer_id
            s_image.save
          end
        end
        if OPTS[:refresh_tile] && layer_id
          puts "refresh tiles ..." if OPTS[:verbose];
          s.make_layer_tiles(layer_id)
        end  
      end
    end
  end
end
