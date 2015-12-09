require 'spec_helper'
require 'orochi_for_medusa/commands/ditto'
include MedusaRestClient

module OrochiForMedusa::Commands
	describe Ditto do
		let(:cui) { Ditto.new(args, :stdin => stdin, :stdout => stdout, :stderr => stderr, :program_name => 'orochi-ditto') }
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
				allow(cui).to receive(:pwd)
			end


			describe "without id" do
				let(:args){ [] }
				let(:id){ '0000000-001'}
				it {
					expect(stdin).to receive(:gets).and_return(id, nil)
					expect(cui).to receive(:act).with(id)
					subject
				}
			end

			describe "with ids" do
				let(:args){ [id_1, id_2] }
				let(:id_1){ '0000000-001'}
				let(:id_2){ '0000000-002'}
				it {
					expect(cui).to receive(:act).with(id_1)
					expect(cui).to receive(:act).with(id_2)
					subject
				}

			end
		end

		describe "ditto" do
			subject { cui.ditto obj }
			let(:id) { '000000-001' }
			let(:obj) { double("record", :name => 'dummy', :global_id => id).as_null_object }
			let(:repl) { double("record").as_null_object }

			before do
				cui.parse_options
			end
			context "with box" do
				it {
					allow(obj).to receive(:kind_of?).with(Box).and_return(true)
					allow(Box).to receive(:new).and_return(repl)
					expect(repl).to receive(:name=).with("#{obj.name}-copy")
					expect(repl).to receive(:save)
					subject
				}
			end

			context "with stone" do
				it {
					allow(obj).to receive(:kind_of?).with(Box).and_return(false)
					allow(obj).to receive(:kind_of?).with(Specimen).and_return(true)
					allow(Specimen).to receive(:new).and_return(repl)
					expect(repl).to receive(:name=).with("#{obj.name}-copy")
					expect(repl).to receive(:save)
					subject
				}
			end

			context "with other" do
				it {
					allow(obj).to receive(:kind_of?).with(Box).and_return(false)
					allow(obj).to receive(:kind_of?).with(Specimen).and_return(false)
					expect{ subject }.to raise_error("Class unsupported")
				}
			end
		end

		describe "act" do		
			subject { cui.act id }
			let(:id) { '000000-001' }
			let(:obj) { double("record", :name => 'dummy', :global_id => id).as_null_object }
			let(:rpl) { double("record", :name => 'dummy-copy', :global_id => "00003").as_null_object }

			before do
				cui.parse_options
				cui.instance_variable_set(:@rpl, rpl)
				allow(Record).to receive(:find_by_id_or_path).with(id).and_return(obj)
				allow(cui).to receive(:ditto).with(obj)				
			end
			it {
				expect(Record).to receive(:find_by_id_or_path).with(id).and_return(obj)
				subject
			}
			context "with --recursive" do
				let(:args){ ['--recursive']}
				it {
					expect(cui).to receive(:rec).with(obj)
					subject
				}
			end
		end

		describe "rec", :current => true do
			subject { cui.rec obj }
			let(:id) { '000000-001' }
			let(:obj) { double("record", :name => 'dummy', :global_id => id, :boxes => [box_1, box_2]).as_null_object }
			let(:rpl) { double("record", :name => 'dummy-copy', :relatives => [], :global_id => "00003").as_null_object }
			let(:box_1) { double("record", :name => 'box-1', :global_id => "00003").as_null_object }
			let(:box_2) { double("record", :name => 'box-2', :global_id => "00004").as_null_object }

			before do
				cui.instance_variable_set(:@rpla, rpl)
			end

			it {
				expect(cui).to receive(:ditto).with(box_1)
				expect(cui).to receive(:ditto).with(box_2)				
				subject
			}
		end

	end
end