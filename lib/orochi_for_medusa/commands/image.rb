require 'orochi_for_medusa/cui'
module OrochiForMedusa::Commands
  class Image < OrochiForMedusa::Cui
    def option_parser
      opts = OptionParser.new do |opt|
        opt.banner = <<-"EOS".unindent
          NAME
            #{program_name} - Download imagefile

          SYNOPSIS
            #{program_name} [options] id

          DESCRIPTION
            Search on service by Medusa by ID and download imagefile with 
            imageometryfile.

          EXAMPLE
            To obtain imagefile with imageometryfile, issue following.
            $ orochi-image      20150327112504-048340

            To obtain imageometryfile without imagefile, issue following.
            $ orochi-image --geo 20150327112504-048340

          SEE ALSO
            orochi-ls
            orochi-cd
            orochi-pwd
            orochi-name
            http://dream.misasa.okayama-u.ac.jp
            https://github.com/misasa/orochi-for-medusa/blob/master/lib/orochi_for_medusa/commands/ls.rb

          IMPLEMENTATION
            Orochi, version 9
            Copyright (C) 2015-2020 Okayama University 
            License GPLv3+: GNU GPL version 3 or later

          OPTIONS
        EOS
        opt.on("-v", "--[no-]verbose", "Run verbosely") {|v| OPTS[:verbose] = v}
        opt.on("--geo", "Download imageometryfile only") {|v| OPTS[:geo] = v}
      end
      opts
    end

    def execute
      ids = argv.clone
      
      if ids.join.blank?
        raise "Specify IMAGE-ID"
      else 
        ids.each do |arg|
          ls(arg)
        end
      end

    end

    def download_file(obj)
        uri = File.join(MedusaRestClient.site, obj.original_path)
        File.open(obj.name, "wb") do |file|
            file.write open(uri).read
        end
    end

    def ls(arg)
      obj = Record.find_by_id_or_path(arg)
      if obj.kind_of?(AttachmentFile)
        basename = File.basename(obj.name,".*")
        obj.dump_geofile(basename + ".geo")
        download_file(obj) unless OPTS[:geo]
      else
        raise "Invalid IMAGE-ID: #{arg}"
      end
    end

    def output_entry(entry)
      mod = ""
      if OPTS[:l]
        if entry.kind_of?(Box)
          mod << "b"
        else
          mod << "-"
        end
        mod << "---------"

        puts sprintf("%7s  %30s  %s", mod, entry.global_id, entry.name )
      elsif OPTS[:id]
        puts entry.global_id
      else
        puts entry.name
      end
      # if OPTS[:analysis]
      #   entry.analyses.each do |analysis|
      #     puts analysis.global_id
      #   end
      # end
    end

    def tab_out(obj)
      if OPTS[:analysis]
        obj.analyses.each do |analysis|
          output_entry(analysis)
        end
      elsif OPTS[:file]
        obj.attachment_files.each do |file|
          output_entry(file)
        end
      elsif OPTS[:bib]
        obj.bibs.each do |bib|
          output_entry(bib)
        end
      else
        output_entry(obj)
        # elsif OPTS[:relatives]
        #   obj.relatives.each do |relative|
        #     output_entry(relative)
        #   end
        #   return
        # end
      end
    end

    def census(obj)
      if OPTS[:box]
        tab_out(obj) if obj.kind_of?(Box)
      else
        tab_out(obj)
      end
      if OPTS[:recursive]
        unless obj.boxes.empty?
          box_children = obj.boxes
          box_children.each do |box_child|
            census(box_child)
          end
        end
        unless obj.stones.empty? and OPTS[:box]
          stone_children = obj.stones
          stone_children.each do |stone_child|
            census(stone_child)
          end
        end
      end
    end
  end
end