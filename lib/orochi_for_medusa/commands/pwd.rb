require 'orochi_for_medusa/cui'
module OrochiForMedusa::Commands
  class Pwd < OrochiForMedusa::Cui
    def option_parser
      opts = OptionParser.new do |opt|
        opt.banner = <<-"EOS".unindent
          NAME
            #{program_name} - Print full hierarchy of orochi working box.

          SYNOPSIS
            #{program_name} [options] id0 [id1 ...]

          DESCRIPTION 
            Print full tenant hierarchy of orochi working box.  With option,
            print full genetic hierarchy of the orochi working stone.  If
            argument is empty, box or stone in environmental variable
            OROCHI_PWD is surveyed.

          SEE ALSO
            orochi-cd
            orochi-ls
            http://dream.misasa.okayama-u.ac.jp

          IMPLEMENTATION
            Orochi, version 9
            Copyright (C) 2015 Okayama University
            License GPLv3+: GNU GPL version 3 or later

          OPTIONS
        EOS
        opt.on("-v", "--[no-]verbose", "Run verbosely") {|v| OPTS[:verbose] = v}        
        opt.on("--stone", "Print genetic hierarchy") {|v| OPTS[:stone] = v}
        opt.on("--id", "Display ID") {|v| OPTS[:id] = v}
        opt.on("--top", "Show godfather") {|v| OPTS[:top] = v}
        opt.on("--id", "Show ID") {|v| OPTS[:id] = v}
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
                pwd(arg)
            end
          end
      else 
        ids.each do |arg|
              pwd(arg)
          end
      end
    end 

        def get_ancestors(obj)
          objs = []
          objs.unshift(obj)
          while obj.parent.present?
            obj = obj.parent
            objs.unshift(obj)
          end
          objs
        end

    def pwd(arg)
        obj = Record.find_by_id_or_path(arg)
        if OPTS[:stone]
          objs = get_ancestors(obj)    
        else
          box = obj.box
          if box
              objs = get_ancestors(box)
              objs.push(obj)
          else
              objs = [box]
          end
        end
        objs = [objs.shift] if OPTS[:top]
        if objs == [nil]
          stdout.puts '/'
        else
          if OPTS[:id]
              objs.each do |obj|
                stdout.puts obj.global_id
              end
          else
              if OPTS[:top]
                stdout.puts objs.map{|obj| obj.name }.join('/')
              else
                stdout.puts '/' + objs.map{|obj| obj.name }.join('/')
              end
          end
        end
    end

  end
end
