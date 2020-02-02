require 'orochi_for_medusa/cui'
module OrochiForMedusa::Commands
  class Mv < OrochiForMedusa::Cui
    def option_parser
      opts = OptionParser.new do |opt|
        opt.banner = <<-"EOS".unindent
          NAME
            #{program_name} - Store a stone to a box

          SYNOPSIS
            #{program_name} [options] stone    [stone2 ... ] box
            #{program_name} [options] stone    [child2 ... ] stone-parent
            #{program_name} [options] stone    [stone2 ... ] bib
            #{program_name} [options] stone    [stone2 ... ] table
            #{program_name} [options] stone    [stone2 ... ] place
            #{program_name} [options] analysis [stone2 ... ] stone

          DESCRIPTION
            Store a stone to a box.  Or set a stone as a child.
            Or linke a stone to bib, table, and place.  Or link an analysis
            to stone.  To rename stone (or something else) use `orochi-rename'.

            To cut parent-children relationships, feed `nobody' as last
            argument instead of parent ID.  In a smilar fashion, to remove
            stone from box, feed `/' as last argument instead of box ID.

          SEE ALSO
            orochi-rename
            http://dream.misasa.okayama-u.ac.jp
            https://github.com/misasa/orochi-for-medusa/blob/master/lib/orochi_for_medusa/commands/mv.rb

          IMPLEMENTATION
            Orochi, version 9
            Copyright (C) 2015-2019 Okayama University
            License GPLv3+: GNU GPL version 3 or later

          OPTIONS
        EOS
        opt.on("-v", "--[no-]verbose", "Run verbosely") {|v| OPTS[:verbose] = v}
        opt.on("-i", "--interactive", "Run interactively") {|v| OPTS[:interactive] = v}
      end
      opts
    end

    def execute
      raise "invalid args" if argv.length < 2
      parent_id = argv.pop
      children_id = argv
      mv(parent_id, children_id)
    end

    def mv(parent_id, children_id)

      OPTS[:nobody] = :v if parent_id == "nobody"
      OPTS[:nobox]  = :v if parent_id == "/"

      parent_obj  = Record.find(parent_id) unless OPTS[:nobody] or OPTS[:nobox]
      p parent_obj       if OPTS[:verbose]
      if OPTS[:verbose]
        # child_obj = child_obj.reload
        print "--> parent_obj "
        p parent_obj
      end

      children_id.each do |id|
        child_obj = Record.find(id)
        if OPTS[:interactive]
          if OPTS[:nobody]
            print "Are you sure you want to cut #{child_obj.name} <#{child_obj.id}> off from its parent <#{child_obj.parent_id}>? [Y/n/!] "
          elsif OPTS[:nobox]
            print "Are you sure you want to kick #{child_obj.name} <#{child_obj.id}> out from its box <#{child_obj.box_id}>? [Y/n/!] "
          else
            print "Are you sure you want to adopt #{child_obj.name} <#{child_obj.id}> to #{parent_obj.name} <#{parent_obj.id}>'s? [Y/n/!] "
          end
          answer = (STDIN.gets)[0].downcase
          if answer == "y" or answer == "\n"
            puts "You chose yes to this record" if OPTS[:verbose]
          elsif answer == "!"
            OPTS[:interactive] = false
            puts "You chose yes to all" if OPTS[:verbose]
          else
            puts "You chose no for this record" if OPTS[:verbose]
            next
          end
        end
        if OPTS[:nobody]
          child_obj.parent_id = nil
          child_obj.save
        elsif OPTS[:nobox]
          child_obj.box_id = nil
          child_obj.save
        else
          # parent_obj.stones << child_obj
          parent_obj.relatives << child_obj
          #  if parent_obj.class == Stone or child_obj.class == Box
          #   child_obj.parent_id = parent_obj.id
          # elsif parent_obj.class == Box
          #   child_obj.box_id = parent_obj.id
          # else
          #   puts "Class of parent and/or children unsupported"
          #   next
          # end
          #  child_obj.save
        end
        if OPTS[:verbose]
          child_obj = child_obj.reload
          print "--> child_obj "
          p child_obj
        end
      end
    end
  end
end
