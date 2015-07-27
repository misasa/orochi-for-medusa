require 'spec_helper'
require 'orochi_for_medusa/commands/uniq'
include MedusaRestClient

module OrochiForMedusa::Commands
	describe Uniq do
		let(:cui) { Uniq.new(args, :stdin => stdin, :stdout => stdout, :stderr => stderr, :program_name => 'orochi-uniq') }
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


		describe "get_and_put" do
			subject { cui.get_and_put id }
			let(:id){ "0000-0001" }
			let(:obj){ double("record").as_null_object }
			before do
				allow(Record).to receive(:find_by_id_or_path).with(id).and_return(obj)
				cui.instance_variable_set(:@godfathers, [])
				cui.instance_variable_set(:@args, [])

			end

			it {
				subject
				expect(cui.instance_variable_get(:@godfathers)).to include(obj)				
				expect(cui.instance_variable_get(:@args)).to include(obj)
			}

		end

		describe "output" do
			subject { cui.output obj }
			let(:obj){ double("record", :name => "test-sample", :global_id => "0000-0001").as_null_object }
			it {
				expect(stdout).to receive(:puts).with(obj.global_id)
				subject
			}
		end

		describe "execute" do		
			subject { cui.execute }
			let(:obj){ double("record").as_null_object }
			before do
				cui.parse_options
			end


			describe "without id" do
				let(:args){ [] }
				let(:id){ '0001'}


				it {
					expect(stdin).to receive(:gets).and_return(id, nil)
					expect(cui).to receive(:get_and_put).with(id)
					subject
 				}
			end

			describe "with id" do
				let(:args){ [id] }
				let(:id){ '0001'}
				it {
					expect(cui).to receive(:get_and_put).with(id)
					subject
 				}
			end

		end

	end
end