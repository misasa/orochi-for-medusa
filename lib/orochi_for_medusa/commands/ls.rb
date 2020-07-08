require 'orochi_for_medusa/cui'
module OrochiForMedusa::Commands
  class Ls < OrochiForMedusa::Cui
    def option_parser
      opts = OptionParser.new do |opt|
        opt.banner = <<-"EOS".unindent
          NAME
            #{program_name} - List box contents

          SYNOPSIS
            #{program_name} [options] id0 [id1 ...]

          DESCRIPTION
            List box contents or daughters.  Search on service by Medusa by ID and list
            `stones and boxes' or `daughters' depending on owner of ID to be
            box or stone.  If argument is empty, ID in environmental variable
            `OROCHI_PWD' is fed.  To obtain name of certain ID, call
            `orochi-name'.  To obtain godfather, call `orochi-pwd --top'

          EXAMPLE
            To obtain list of daughters, issue either followings.
            $ orochi-ls      20150327112504-048340
            $ orochi-ls --id 20150327112504-048340 | orochi-pwd
            $ orochi-ls --id --recursive 20150327112504-048340 20101015100407679.hkitagawa

            To obtain stone tree, issue following.
            $ orochi-ls -r --id 20150327112504-048340 | orochi-pwd

          SEE ALSO
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
        opt.on("-l", "Use a long listing format"){|v| OPTS[:l] = v}
        # opt.on('-o outfile','-f outfile') {|v| OPTS[:o] = v}
        opt.on("--id", "Display ID") {|v| OPTS[:id] = v}
        opt.on("-r", "--recursive", "List subitems recursively") {|v| OPTS[:recursive] = v}
        opt.on("--analysis", "Show analysis records") {|v| OPTS[:analysis] = v}
        opt.on("--file", "Show attachment_file records") {|v| OPTS[:file] = v}
        opt.on("--bib", "Show bib records") {|v| OPTS[:bib] = v}
        opt.on("--stone", "Show list of stones") {|v| OPTS[:stone] = v}
        opt.on("--box", "Show list of boxes") {|v| OPTS[:box] = v}
        # opt.on("--relatives", "Show related records") {|v| OPTS[:relatives] = v}
      end
      opts
    end

    def execute
      if argv.length < 1
        ids = [ENV["OROCHI_PWD"]]
      else
        ids = argv.clone
      end
      
      if ids.join.blank?
        while answer = stdin.gets do
          answer.split.each do |arg|
            ls(arg)
          end
        end
      else 
        ids.each do |arg|
          ls(arg)
        end
      end

    end


    def ls(arg)
      obj = Record.find_by_id_or_path(arg)
      if OPTS[:recursive]
        tab_out(obj)
      else
        if OPTS[:analysis] or OPTS[:file] or OPTS[:bib]
          tab_out(obj)
          return
        end
      end
      if obj.kind_of?(Box)
        # puts "#{arg}:" if $id.size > 1
        obj.entries.each do |entry|
          census(entry)
        end
      elsif OPTS[:box]
        raise "Class unsupported"
      else
        # census(obj)
        obj.stones.each do |stone|
          census(stone)
        end
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
