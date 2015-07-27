require 'spec_helper'
require 'orochi_for_medusa/commands/upload'
include MedusaRestClient

module OrochiForMedusa::Commands
	describe Upload do
		let(:cui) { Upload.new(args, :stdin => stdin, :stdout => stdout, :stderr => stderr, :program_name => 'orochi-upload') }
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


		describe "upload" do
			subject { cui.upload file }
			context "with jpg" do
				let(:file){ "0000-0001.jpg" }

				it {
					expect(AttachmentFile).to receive(:upload).with(file)
					subject
				}
			end

			context "with pml" do
				let(:file){ "0000-0001.pml" }

				it {
					expect(cui).to receive(:system_execute).with("casteml upload #{file}")
					subject
				}
			end

			# it {
			# 	subject
			# 	expect(cui.instance_variable_get(:@godfathers)).to include(obj)				
			# 	expect(cui.instance_variable_get(:@args)).to include(obj)
			# }

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
					expect(cui).to receive(:upload).with(id)
					subject
 				}
			end

			describe "with id" do
				let(:args){ [id] }
				let(:id){ '0001'}
				it {
					expect(cui).to receive(:upload).with(id)
					subject
 				}
			end

		end

	end
end