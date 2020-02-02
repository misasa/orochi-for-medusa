# coding: utf-8
require 'orochi_for_medusa/cui'
require 'open3'
module OrochiForMedusa::Commands
  class Url < OrochiForMedusa::Cui
    def option_parser
      opts = OptionParser.new do |opt|
        opt.banner = <<-"EOS".unindent
NAME
  #{program_name} - Show record in starndard output by curl and w3m

SYNOPSIS AND USAGE
  #{program_name} [options] [URL]

DESCRIPTION
  Show record in starndard output by curl and w3m.  Really this
  obtains page and render a Medusa URL rendered text.  This will
  obtain page content by `curl' through basic authorization and
  render it by `w3m', then filter out header and footer by itself.
  This gets authorization information from `~/.orochirc'.

  Essence of this program is shown below.
    curl --user user:password -s http://database.misasa.okayama-u.ac.jp/stone/specimens/634 |
    w3m -T text/html -dump

EXAMPLE
  $ orochi-url http://database.misasa.okayama-u.ac.jp/stone/specimens/634

  yttrium standard solution, 47012-1B, Kanto 1 < 20150521115620-135759 >
  - yttrium standard solution, 47012-1B, Kanto11\me
  - ISEI/main/clean-lab/ICP-MS/tuning solutions/me
  - daughter (1) / analysis / bib / file (1)
  - classification: unknown
  - physical_form: solution
  - quantity (ml): 100.0
  - description: 47012-1B
  - modified at yesterday, 5:47
  $ orochi-url --id 20150521110909-111103
    ...

SEE ALSO
  curl
  w3m
  http://dream.misasa.okayama-u.ac.jp
  https://github.com/misasa/orochi-for-medusa/blob/master/lib/orochi_for_medusa/commands/url.rb

IMPLEMENTATION
  Orochi, version 9
  Copyright (C) 2015-2020 Okayama University
  License GPLv3+: GNU GPL version 3 or later

HISTORY
  May 25, 2015: MY writes the first version

ARGUMENTS AND OPTIONS
EOS
        opt.on("-v", "--[no-]verbose", "Run verbosely") {|v| cmd_options[:verbose] = v}
        opt.on("-i", "--interactive", "Run interactively") {|v| cmd_options[:interactive] = v}
        opt.on("--id", "Guess URL by ID") {|v| cmd_options[:id] = v}
      end
      opts
    end

    def transfer_and_render(url_or_id)
      user = Base.user
      password = Base.password

      if cmd_options[:id]
        obj = Record.find_by_id_or_path(url_or_id)
        if obj.kind_of?(Box)
          klass = "boxes"
        # elsif obj.kind_of?(Stone)
        #   klass = "stones"
        elsif obj.kind_of?(Specimen)
          klass = "specimens"
        elsif obj.kind_of?(Analysis)
          klass = "analyses"
        elsif obj.kind_of?(Place)
          klass = "places"
        elsif obj.kind_of?(Bib)
          klass = "bibs"
        elsif obj.kind_of?(AttachmentFile)
          klass = "attachment_files"
        else
          raise "#{obj.class} not supported"
        end
        url = "http://database.misasa.okayama-u.ac.jp/stone/#{klass}/#{obj.id}"
      else
        url = url_or_id
      end
      cmd = "curl --user #{user}:#{password} -s #{url} | w3m -T text/html -dump -t 4 -S -cols 256"
      status = []
      if cmd_options[:verbose]
        # stdout.puts cmd
        stderr.print "--> I will parse output by <#{cmd}>\n"
      end
      Open3.popen3(cmd) do |pstdin, pstdout, pstderr|
        # err = stderr.read
        # unless err.blank?
        #   p err
        # end
        outputs =  pstdout.read
        outputs.each_line do |line|
          line = line.strip
          line.gsub!(/\s+/," ")
          next if line =~ /^$/
          stdout.puts line
          # ## typical output
          # stdout.puts line                    if line =~ /\<.*\>/
          # # stdout.puts line                  if line =~ /／me/
          # stdout.puts line.sub(/^\s*•\s*/,"") if line =~ /• classification:/
          # stdout.puts line.sub(/^\s*•\s*/,"") if line =~ /• physical-form/
          # stdout.puts line.sub(/^\s*•\s*/,"") if line =~ /• quantity.*\(.*\)/
          # stdout.puts line.sub(/^\s*•\s*/,"") if line =~ /• description/
          # stdout.puts line.sub(/^\s*•\s*/,"") if line =~ /• modified/

          # ## reconstruct status
          # status.push(line.delete("• ").chomp) if line =~ /• daughter/
          # status.push(line.delete("• ").chomp) if line =~ /• history/
          # status.push(line.delete("• ").chomp) if line =~ /• analysis/
          # status.push(line.delete("• ").chomp) if line =~ /• bib/
          # status.push(line.delete("• ").chomp) if line =~ /• file/
        end
        # status.shift(3) # hard code
        # stdout.puts status.join("/ ")
      end
    end

    def execute
      if argv.length < 1
        while answer = stdin.gets do
          answer.split.each do |id|
            transfer_and_render(id)
          end
        end
      else argv.each do |id|
             transfer_and_render(id)
           end
      end
    end
  end
end
