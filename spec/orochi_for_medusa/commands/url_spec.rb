require 'spec_helper'
require 'orochi_for_medusa/commands/url'
include MedusaRestClient

module OrochiForMedusa::Commands
	describe Url do
		let(:cui) { Url.new(args, :stdin => stdin, :stdout => stdout, :stderr => stderr, :program_name => 'orochi-url') }
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
					expect(cui.cmd_options).to include(:verbose => true)
				}
			end

		end


		describe "execute" do		
			subject { cui.execute }
			before do
				cui.parse_options
			end


			describe "without url" do
				let(:args){ [] }
				let(:id){ '0001'}

				it {
					expect(stdin).to receive(:gets).and_return(id, nil)
					expect(cui).to receive(:transfer_and_render).with(id)
					subject
 				}
			end

			describe "with url" do
				let(:args){ [id] }
				let(:id){ '0001'}
				it {
					expect(cui).to receive(:transfer_and_render).with(id)
					subject
 				}
			end

		end

		describe "transfer_and_put" do
			subject { cui.transfer_and_render url }
			let(:url){ "http://database.misasa.okayama-u.ac.jp/stone/stones/19745" }
			let(:user){ "hoge"}
			let(:password){ "fuga" }
			let(:html){ File.open("spec/fixtures/files/stone-19750.html"){|f| f.read } }
			let(:command){ "curl --user #{user}:#{password} -s #{url} | \ w3m -T text/html -dump" }
			let(:file_io){ File.open("spec/fixtures/files/stone-19750.html")}
			before do
				Base.user = user
				Base.password = password
				response = []
				response << 'stdin'
				response << file_io
				response << 'stderr'
				allow(Open3).to receive(:popen3).with(command).and_yield(*response)
			end
			it {
				expect(stdout).to receive(:puts).with(command).ordered
				expect(stdout).to receive(:puts).with("hematite-oujda < 20150522154125-469960 >\n").ordered				
				expect(stdout).to receive(:puts).with("ISEI／main／5f／Vacuum Desiccator 1／me\n").ordered
				expect(stdout).to receive(:puts).with("classification:mineral\n").ordered
				expect(stdout).to receive(:puts).with("physical_form:chunk\n").ordered
				expect(stdout).to receive(:puts).with("modifiedat2015-05-25\n").ordered
				expect(stdout).to receive(:puts).with("daughter(3)/ analysis/ bib/ file(1)").ordered
				subject
			}
		end


	end
end