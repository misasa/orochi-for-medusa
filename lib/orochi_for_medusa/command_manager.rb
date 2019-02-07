module OrochiForMedusa
  class CommandManager
    def self.instance
      @command_manager ||= new
    end

    def self.commands
      @commands ||= get_commands
    end

    def self.get_commands
      commands_dir = File.expand_path('../commands', __FILE__)
      paths = Dir.glob(File.join(commands_dir, "*")).sort.map{|path| File.basename(path, ".rb")}
    end

    def self.orochi_commands
      commands.map{|cmd| cmd.gsub(/\_/, '-') }
    end

    def load_and_instantiate(command_name, args, opts = {})
      require "orochi_for_medusa/commands/#{command_name}"
      const_name = command_name.capitalize.gsub(/_(.)/) { $1.upcase }
      OrochiForMedusa::Commands.const_get(const_name).new(args, opts)
    end
  end
  module Commands
  end
end