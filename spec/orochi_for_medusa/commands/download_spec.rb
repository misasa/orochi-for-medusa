require 'spec_helper'
require 'orochi_for_medusa/commands/download'
include MedusaRestClient

module OrochiForMedusa::Commands
	describe Download do
		let(:cui) { Download.new(args, :stdin => stdin, :stdout => stdout, :stderr => stderr, :program_name => 'orochi-download') }
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

			describe "with --id" do
				let(:args){ ["--id"] }
				it { 
					subject
					expect(cui.options).to include(:id => true)
				}
			end

		end

		describe "execute" do		
			subject { cui.execute }
			before do
				cui.parse_options
				allow(cui).to receive(:get_and_put)
			end


			describe "without id" do
				let(:args){ [] }
				let(:id){ '0000000-001'}
				it {
					expect(stdin).to receive(:gets).and_return(id, nil)
					expect(cui).to receive(:get_and_put).with(id)
					subject
				}
			end

			describe "with ids" do
				let(:args){ [id_1, id_2] }
				let(:id_1){ '0000000-001'}
				let(:id_2){ '0000000-002'}
				it {
					expect(cui).to receive(:get_and_put).with(id_1)
					expect(cui).to receive(:get_and_put).with(id_2)
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