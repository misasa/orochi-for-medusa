require 'spec_helper'

module OrochiForMedusa
	describe Cui do
		let(:cui) { OrochiForMedusa::Cui.new(args, :stdout => stdout, :stderr => stderr) }
		let(:args){ [] }
		let(:stdout){ Output.new }
		let(:stderr){ Output.new }
		
		describe "parse_options" do
			subject { cui.parse_options }
			describe "with -h", :show_help => true do
				let(:args){ ["-h"] }
				it { expect{ subject }.to raise_error(SystemExit) }
			end

			describe "with -v" do
				let(:args){ ["-v"] }
				it { 
					subject
					expect(cui.options).to include(:verbose => true)
				}
			end
		end

		describe "run" do
			subject { cui.run }
			context "execute raise error" do
				let(:error_msg){ "wrong args" }
				before do
					allow(cui).to receive(:execute).and_raise(error_msg)
				end
				it {
					expect(stderr).to receive(:puts).with("error: #{error_msg}")
					expect{ subject }.to exit_with_code(1)
				}
			end
		end
	end
end