require 'orochi_for_medusa/cui'
module OrochiForMedusa::Commands
  class Ditto < OrochiForMedusa::Cui
    def option_parser
      opts = OptionParser.new do |opt|
        opt.banner = <<-"EOS".unindent
          NAME
            #{program_name} - Clone box recursively

          SYNOPSIS
            #{program_name} [options] box

          DESCRIPTION
            Clone box recursively.  Stones in box also are duplicated.
            Genetic relationship to ancestor is maintained on this process.

          SEE ALSO
            http://dream.misasa.okayama-u.ac.jp

          IMPLEMENTATION
            Orochi, version 9
            Copyright (C) 2015 Okayama University
            License GPLv3+: GNU GPL version 3 or later

          OPTIONS
        EOS
        opt.on("-v", "--[no-]verbose", "Run verbosely") {|v| OPTS[:verbose] = v}    
        opt.on("-R", "--recursive", "Run recursively") {|v| OPTS[:recursive] = v}
      end
      opts
    end

    def ditto(tmp)
      if tmp.kind_of?(Box)
        @rpl = Box.new
      elsif tmp.kind_of?(Specimen)
        @rpl = Specimen.new
      else 
        raise "Class unsupported"
      end
      @rpl.name = "#{tmp.name}-copy"
      p @rpl.name
      @rpl.save
    end

    def act(arg)
      obj = Record.find_by_id_or_path(arg)
      ditto(obj)
      if @rpl.kind_of?(Specimen) 
        @rpl.box_id = obj.box_id
        @rpl.save
      end
      unless obj.parent == nil
        obj.parent.relatives << @rpl
      end
      @rpla = @rpl.reload
      p @rpla
      if OPTS[:recursive]
        rec(obj)
      end
    end

    def rec(cld)
      #p cld.boxes.empty?
      unless cld.boxes.empty?
        rlts = cld.boxes
      else
        rlts = cld.specimens
      end
      if rlts.empty?
        puts "nil"
      else
        rlts.each do |rlt|
          ditto(rlt)
          @rpla.relatives << @rpl
          cld = rlt
        end
        @rpla = @rpl
        p cld
        rec(cld)
      end
    end


    def execute
      ids = argv.clone
      if ids.join.blank?
          while answer = stdin.gets do
            answer.split.each do |arg|
                act(arg)
            end
          end
      else 
        ids.each do |arg|
              act(arg)
          end
      end
    end

  end
end