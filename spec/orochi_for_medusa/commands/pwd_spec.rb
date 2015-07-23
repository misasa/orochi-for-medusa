require 'spec_helper'
require 'orochi_for_medusa/commands/pwd'
include MedusaRestClient

module OrochiForMedusa::Commands
	describe Pwd do
		let(:cui) { Pwd.new(args, :stdin => stdin, :stdout => stdout, :stderr => stderr, :program_name => 'orochi-cd') }
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
				allow(cui).to receive(:pwd)
			end

			describe "with ENV" do
				let(:args){ [] }
				let(:id){ '0000000-001'}
				before do
					ENV["OROCHI_PWD"] = id
				end
				it { 
					expect{ subject }.not_to raise_error
				}
				it {
					expect(cui).to receive(:pwd).with(id)
					subject
				}
			end


			describe "without id and ENV" do
				let(:args){ [] }
				let(:id){ '0000000-001'}
				before do
					ENV["OROCHI_PWD"] = nil
				end
				it {
					expect(stdin).to receive(:gets).and_return(id, nil)
					expect(cui).to receive(:pwd).with(id)
					subject
				}
			end

			describe "with ids" do
				let(:args){ [id_1, id_2] }
				let(:id_1){ '0000000-001'}
				let(:id_2){ '0000000-002'}
				it {
					expect(cui).to receive(:pwd).with(id_1)
					expect(cui).to receive(:pwd).with(id_2)
					subject
				}

			end
		end

		describe "pwd" do		
			subject { cui.pwd id }
			let(:id) { '000000-001' }
			let(:obj) { double("record", :name => 'dummy', :global_id => id).as_null_object }
			let(:obj_1){ double("record", :name => 'dummy_1', :global_id => "0001").as_null_object }
			let(:obj_2){ double("record", :name => 'dummy_2', :global_id => "0002").as_null_object }

			before do
				cui.parse_options
				allow(Record).to receive(:find_by_id_or_path).with(id).and_return(obj)
				allow(cui).to receive(:get_ancestors).with(obj).and_return([obj_1, obj_2])				
			end
			it {
				expect(Record).to receive(:find_by_id_or_path).with(id).and_return(obj)
				expect(stdout).to receive(:puts).with("/#{obj_1.name}/#{obj_2.name}/#{obj.name}")
				subject
			}
			context "with --id option" do
				let(:args){ ['--id'] }
				it {
					expect(stdout).to receive(:puts).once.ordered.with(obj_1.global_id)
					expect(stdout).to receive(:puts).once.ordered.with(obj_2.global_id)
					expect(stdout).to receive(:puts).once.ordered.with(obj.global_id)
					subject
				}

			end
		end
	end
end