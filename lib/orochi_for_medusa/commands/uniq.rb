require 'orochi_for_medusa/cui'
module OrochiForMedusa::Commands
  class Uniq < OrochiForMedusa::Cui
    def option_parser
      opts = OptionParser.new do |opt|
        opt.banner = <<-"EOS".unindent
          NAME
            #{program_name} - Write only one stone per family

          SYNOPSIS AND USAGE
            #{program_name} [options] stone0 [stone1 ...]

          DESCRIPTION
            Write only one stone per family.  Look up the godfather of each
            stone given as an argument (or on standard input) and write only
            one stone per family to standard output.  Arguments are stone-IDs.

          EXAMPLE
            $ orochi-uniq 20110514185257-135-219 20120224090706-479-109 20120224090715-052-770
            20110514185257-135-219
            $ orochi-uniq --godfather 20110514185257-135-219 20120224090706-479-109 20120224090715-052-770
            20110416135129-112-853

          SEE ALSO
            uniq
            http://dream.misasa.okayama-u.ac.jp
            https://github.com/misasa/orochi-for-medusa/blob/master/lib/orochi_for_medusa/commands/uniq.rb

          IMPLEMENTATION
            Orochi, version 9
            Copyright (C) 2015-2021 Okayama University
            License GPLv3+: GNU GPL version 3 or later

          HISTORY
            May 30, 2015: MY writes the first version

          ARGUMENTS AND OPTIONS
        EOS
        opt.on("-v", "--[no-]verbose", "Run verbosely") {|v| OPTS[:verbose] = v}
        opt.on("--godfather", "Write the godfather instead") {|v| OPTS[:godfather] = v}
        opt.on("--name", "Display names instead of IDs") {|v| OPTS[:name] = v}

      end
      opts
    end

    def get_and_put(id)
      obj = Record.find_by_id_or_path(id)
      arg = obj
      objs = []
      objs.unshift(obj)
      while obj.parent.present?
        obj = obj.parent
        objs.unshift(obj)
      end
      godfather = objs.shift
      unless @godfathers.include?(godfather)
        @godfathers.push(godfather)
        @args.push(arg)
      end
      p @godfathers if OPTS[:verbose]
    end

    def output(obj)
      if OPTS[:name]
        stdout.puts obj.name
      else
        stdout.puts obj.global_id
      end
    end

    def execute
      @args = []
      @godfathers = []

      if argv.length < 1
        while answer = stdin.gets do
          answer.split.each do |id|
            get_and_put(id)
          end
        end
      else argv.each do |id|
             get_and_put(id)
           end
      end

      if OPTS[:godfather]
        @godfathers.each do |godfather|
          output(godfather)
        end
      else
        @args.each do |arg|
          output(arg)
        end
      end
    end
  end
end
