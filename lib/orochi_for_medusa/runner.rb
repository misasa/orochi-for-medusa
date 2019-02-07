require 'orochi_for_medusa/command_manager'
module OrochiForMedusa
  class Runner
    def initialize
    end
    def run(args=ARGV, opts = {})
      if command_name = opts[:command_name]
        command_name = opts[:command_name].sub(/orochi-/,"")
        cmd = OrochiForMedusa::CommandManager.instance.load_and_instantiate command_name, args, opts
        cmd.run
      end
    end
  end
end