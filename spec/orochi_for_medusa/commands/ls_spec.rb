require 'spec_helper'
require 'orochi_for_medusa/commands/ls'
include MedusaRestClient

module OrochiForMedusa::Commands
	describe Ls do
		let(:cui) { Ls.new(args, :stdin => stdin, :stdout => stdout, :stderr => stderr, :program_name => 'orochi-ls') }
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
				allow(cui).to receive(:ls)
			end


			describe "without id" do
				let(:args){ [] }
				let(:id){ '0000000-001'}
				it {
					expect(stdin).to receive(:gets).and_return(id, nil)
					expect(cui).to receive(:ls).with(id)
					subject
				}
			end

		end

		# describe "get_and_put", :current => true do
		# 	subject { cui.get_and_put obj }
		# 	let(:obj) { double("record", :name => 'dummy').as_null_object }
		# 	it {
		# 		subject
		# 	}
		# end

	end
end