require 'spec_helper'
require 'orochi_for_medusa/runner'
module OrochiForMedusa
	describe Runner do
		describe "#run" do
			subject { runner.run(args, :command_name => command_name )}
			let(:manager){ OrochiForMedusa::CommandManager.instance }
			let(:runner){ Runner.new }
			let(:command_name){ 'orochi-cd' }
			let(:args){ ['sample'] }
			let(:cmd){ double('cd').as_null_object }
			it {
				expect(manager).to receive(:load_and_instantiate).with('cd', args, {}).and_return(cmd)
				expect(cmd).to receive(:run)
				subject
			}
		end
	end
end