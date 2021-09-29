require 'orochi_for_medusa/cui'
module OrochiForMedusa::Commands
  class RefreshTile < OrochiForMedusa::Cui
    def option_parser
      opts = OptionParser.new do |opt|
        opt.banner = <<-"EOS".unindent
          NAME
            #{program_name} - Refresh tiles in layers on a surface

          SYNOPSIS
            #{program_name} [options] SURFACE_ID [LAYER1, LAYER2 ...]

          DESCRIPTION
            Refresh tiles in layers on a surface. Do not specify layers
            when you want to refresh all layers.

          EXAMPLE
            ## refresh all tiles
            $ #{program_name} 20181122134024-911579

            ## refresh tiles only in layer `BSE'
            $ #{program_name} 20181122134024-911579 BSE

            ## refresh tiles in both layer `BSE' and layer `Raman'
            $ #{program_name} 20181122134024-911579 BSE Raman

          SEE ALSO
            orochi-upload --refresh-tile
            http://dream.misasa.okayama-u.ac.jp
            https://github.com/misasa/orochi-for-medusa/blob/master/lib/orochi_for_medusa/commands/refresh_tile.rb

          HISTORY
            September 24, 2020: First commit

          IMPLEMENTATION
            Orochi, version 9
            Copyright (C) 2015-2021 Okayama University
            License GPLv3+: GNU GPL version 3 or later

          OPTIONS
        EOS
        opt.on("-v", "--[no-]verbose", "Run verbosely") {|v| OPTS[:verbose] = v}
      end
      opts
    end

    def execute
      ActiveResource::Base.logger = Logger.new(STDOUT) if OPTS[:verbose]
      raise "specify surface-ID" if argv.size < 1
      surface_id = argv.shift
      s = Record.find(surface_id)
      if argv.size < 1
        s.make_tiles
      else
        layer_names = s.attributes["layers"].map{|id,name| name }
        argv.each do |layer_name|
          idx = layer_names.index(layer_name)
          if idx.nil?
            puts "layer `#{layer_name}' does not exist in surface `#{s.name}'."
            next
          end
          layer_id = s.attributes["layers"][idx][0]
          s.make_layer_tiles(layer_id)
        end
      end
    end

    def refresh_tile(layer)
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
        #tt = File.basename(t).gsub('x','_').gsub(' ','_')
        tt = opts[:filename].gsub('x','_').gsub(' ','_')
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
          #tt = File.basename(t).gsub('x','_').gsub(' ','_')
          tt = opts[:filename].gsub('x','_').gsub(' ','_')
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
