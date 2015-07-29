require 'spec_helper'
require 'orochi_for_medusa/commands/machine'
include MedusaRestClient

module OrochiForMedusa::Commands
	describe Machine do
		let(:cui) { Machine.new(args, :stdin => stdin, :stdout => stdout, :stderr => stderr, :program_name => 'orochi-machine') }
		let(:args){ [] }
		let(:stdout){ Output.new }
		let(:stderr){ Output.new }
		let(:stdin){ double('stdin').as_null_object }
		describe "show_help", :show_help => true do
			it { 
				puts "-" * 5 + " help start" + "-" * 5
				puts cui.opts 
				puts "-" * 5 + " help end" + "-" * 5
			}
		end

		describe "parse_options" do
			subject { cui.parse_options }

			describe "with -v" do
				let(:args){ ["-v"] }
				it { 
					subject
					expect(cui.options).to include(:verbose => true)
				}
			end

		end

		describe "execute" do		
			subject { cui.execute }
			before do
				cui.parse_options
			end

			describe "with start" do
				let(:args){ [cmd] }
				let(:cmd){ "start" }
				it {
					expect(cui).to receive(:start_session)
					subject
				}

			end

			describe "with sync" do
				let(:args){ [cmd] }
				let(:cmd){ "sync" }

				it {
					expect(cui).to receive(:sync_session)
					subject
				}

			end

			describe "with stop" do
				let(:args){ [cmd] }
				let(:cmd){ "stop" }

				it {
					expect(cui).to receive(:stop_session)					
					subject
				}

			end


		end

	end
end