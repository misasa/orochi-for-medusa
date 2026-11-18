# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'orochi_for_medusa/version'

Gem::Specification.new do |spec|
  spec.name          = "orochi-for-medusa"
  spec.version       = OrochiForMedusa::VERSION
  spec.authors       = ["Yusuke Yachi"]
  spec.email         = ["yyachi@misasa.okayama-u.ac.jp"]
  spec.summary       = "Command-line utilities for Medusa"
  spec.description   = "List, find, name, move, upload, and label Medusa records from the command line, as GNU utilities do for files."
  spec.homepage      = "https://github.com/misasa/orochi-for-medusa"
  spec.license       = "GPL-3.0-or-later"
  spec.required_ruby_version = ">= 2.6.0"

  spec.files         = %w[LICENSE.txt README.md] + Dir['bin/orochi-*'].sort + Dir['lib/**/*.rb'].sort
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "medusa_rest_client", ">= 1.5.2"
  spec.add_dependency "unindent"
  spec.add_dependency "logger", ">= 1.4", "< 2"

  spec.add_development_dependency "bundler", ">= 1.17", "< 5"
  spec.add_development_dependency "rake", ">= 12.3.3", "< 14"
  spec.add_development_dependency "rspec", "~> 3.13"
end
