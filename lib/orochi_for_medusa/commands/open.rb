# coding: utf-8
require 'orochi_for_medusa/cui'
module OrochiForMedusa::Commands
  class Open < OrochiForMedusa::Cui
  def option_parser
    opts = OptionParser.new do |opt|
    opt.banner = <<-"EOS".unindent
NAME
  #{program_name} - Open record by default browser

SYNOPSIS
  #{program_name} [options] id0 [id1 ...]

DESCRIPTION
  Open record by default browser.

SEE ALSO
    http://dream.misasa.okayama-u.ac.jp

IMPLEMENTATION
  Orochi, version 9
  Copyright (C) 2015 Okayama University
  License GPLv3+: GNU GPL version 3 or later

OPTIONS
EOS
    opt.on("-v", "--[no-]verbose", "Run verbosely") {|v| OPTS[:verbose] = v}
    opt.on("--edit", "--edit", "open edit page") {|v| OPTS[:edit] = v}
    end
    opts
  end

  def opurl(arg)
    if arg[0] =~ /[0-9]/
    obj = Record.find(arg)
    if obj.kind_of?(Box)
      klass = "boxes"
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
      raise
    end
    url = "http://database.misasa.okayama-u.ac.jp/stone/#{klass}/#{obj.id}"
    puts url
    else
    url = arg
    puts url
    end

    if OPTS[:edit]
    url = url + "/edit"
    end

    p RUBY_PLATFORM
    if platform =~ /mswin(?!ce)|mingw|bccwin/
    system_execute("start #{url}")
    elsif platform =~ /cygwin/
    system_execute("cygstart #{url}")
    elsif platform =~ /darwin/
    system_execute("open #{url}")
    else
    raise
    end
  end

  def execute
    if argv.length < 1
    while answer = stdin.gets do
      answer.split.each do |id|
      opurl(id)
      end
    end
    else argv.each do |id|
       opurl(id)
       end
    end
  end
  end
end
