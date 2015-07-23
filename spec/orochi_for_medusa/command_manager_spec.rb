require 'spec_helper'
require 'orochi_for_medusa/command_manager'
require 'orochi_for_medusa/commands/cd'
module OrochiForMedusa
	describe CommandManager do
		describe "#load_and_instantiate" do
			subject { manager.load_and_instantiate command_name, args, opts }
			let(:manager){ CommandManager.instance}
			let(:command_name){ 'cd' }
			let(:args){ [] }
			let(:opts){ {} }
			let(:cmd){ double('cd').as_null_object }
			it "returns command instance" do
				expect(OrochiForMedusa::Commands::Cd).to receive(:new).with(args, {})
				subject
			end
		end

	end
end