# Run after bundle install: bundle exec ruby script/verify_package.rb path.gem
# Installs the archive into a temporary gem directory and checks the
# installed commands without contacting a Medusa server.
require 'bundler'
require 'open3'
require 'rbconfig'
require 'rubygems/package'
require 'tmpdir'
require_relative '../lib/orochi_for_medusa/version'

archive = File.expand_path(ARGV.fetch(0))
package = Gem::Package.new(archive)
package.verify
spec = package.spec
abort 'Unexpected gem name or version' unless spec.name == 'orochi-for-medusa' && spec.version.to_s == OrochiForMedusa::VERSION
abort 'Archive filename differs from gemspec' unless File.basename(archive) == spec.file_name

root = File.expand_path('..', __dir__)
commands = Dir.chdir(root) { Dir['lib/orochi_for_medusa/commands/*.rb'].sort }
expected = commands.map { |path| "orochi-#{File.basename(path, '.rb').tr('_', '-')}" }
abort "Executables differ from commands: #{spec.executables.sort.inspect}" unless spec.executables.sort == expected.sort
missing = (%w[LICENSE.txt README.md lib/orochi_for_medusa.rb] + commands) - spec.files
abort "Missing packaged files: #{missing.join(', ')}" unless missing.empty?
extra = spec.files.grep(%r{\A(?:\.github|script|spec)/|Gemfile})
abort "Development files packaged: #{extra.join(', ')}" unless extra.empty?

dependency_paths = (Gem.path + Gem.loaded_specs.values.map(&:base_dir)).uniq
Dir.mktmpdir('orochi-package-') do |directory|
  gem_home = File.join(directory, 'gems')
  environment = {
    'HOME' => directory,
    'GEM_HOME' => gem_home,
    'GEM_PATH' => ([gem_home] + dependency_paths).join(File::PATH_SEPARATOR),
    'OROCHI_PWD' => nil,
    'RUBYLIB' => nil,
    'RUBYOPT' => nil
  }
  File.write(File.join(directory, '.orochirc'), "---\nuri: https://medusa.invalid/\nuser: test\npassword: test\n")
  run = lambda do |*args|
    stdout, stderr, status = Open3.capture3(environment, RbConfig.ruby, *args, chdir: directory)
    abort "Command failed (#{status.exitstatus}): #{args.inspect}\n#{stdout}\n#{stderr}" unless status.success?
    stdout
  end

  # A medusa_rest_client taken from a Git source (see Gemfile) is invisible
  # outside Bundler. Package that checkout so the installed commands can load it.
  client = Gem.loaded_specs['medusa_rest_client']
  if client && !File.file?(File.join(client.base_dir, 'specifications', "#{client.full_name}.gemspec"))
    client_archive = File.join(directory, client.file_name)
    Dir.chdir(client.full_gem_path) do
      builder = Gem::Package.new(client_archive)
      builder.spec = client.dup
      builder.build
    end
  end

  Bundler.with_unbundled_env do
    if client_archive
      run.call('-S', 'gem', 'install', '--local', '--no-document', '--ignore-dependencies', client_archive)
    end
    run.call('-S', 'gem', 'install', '--local', '--no-document', '--ignore-dependencies', archive)
    expected.each do |command|
      executable = File.join(gem_home, 'bin', command)
      abort "Missing installed executable: #{command}" unless File.file?(executable)
      help = run.call(executable, '--help')
      unless help.lines.first&.strip == 'NAME' && help.include?('OPTIONS') && help.include?('--[no-]verbose')
        abort "Unexpected help from #{command}:\n#{help}"
      end
    end

    run.call('-e', <<~'CHECK', spec.name, spec.version.to_s, gem_home)
      name, version, gem_home = ARGV
      gem name, "= #{version}"
      require 'orochi_for_medusa'
      installed = Gem.loaded_specs.fetch(name)
      abort 'orochi-for-medusa loaded from outside the temporary installation' unless File.realpath(installed.base_dir) == File.realpath(gem_home)
      abort 'Installed version differs' unless OrochiForMedusa::VERSION == version
    CHECK
  end
end
puts "PASS #{spec.full_name}: archive, #{expected.size} installed commands and library (Ruby #{RUBY_VERSION})"
