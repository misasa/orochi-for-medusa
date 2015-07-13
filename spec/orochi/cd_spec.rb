require 'spec_helper'

module Orochi
	describe Cd do
		let(:cui) { Orochi::Cd.new(args, :stdout => stdout, :stderr => stderr, :program_name => 'orochi-cd') }
		let(:args){ [] }
		let(:stdout){ Output.new }
		let(:stderr){ Output.new }
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
			end
			describe "without path" do
				let(:args){ [] }
				it { 
					expect{ subject }.to raise_error(RuntimeError, "specify path")
				}
			end

			describe "with path" do
				let(:args){ [path] }
				let(:path){ '/somewhere/box-1' }
				let(:id){ '0000000-0000001' }
				before do
					cui
					allow(Box).to receive(:chdir).with(path).and_return(true)
					allow(Box).to receive(:pwd).and_return(path)
					allow(Box).to receive(:pwd_id).and_return(id)
				end
				context "Box.chdir returns true", :current => true do
					it { 
						expect(Box).to receive(:chdir).with(path).and_return(true)
						expect(Box).to receive(:pwd).and_return(path)
						#expect(Box).not_to receive(:pwd)
						expect(stdout).to receive(:puts).with(path)
						subject
					}
				end

				context "Box.chdir returns false" do
					it { 
						expect(Box).to receive(:chdir).with(path).and_return(false)
						expect(Box).not_to receive(:pwd)
						expect(stdout).not_to receive(:puts).with(path)
						expect{ subject }.to raise_error(RuntimeError, "could not change directory to #{path}")
					}
				end


				context "with --id" do
					let(:args){ [path, '--id'] }
					it {
						cui.parse_options
						expect(cui.options).to include(:id => true)
					}
					it {
						expect(Box).to receive(:chdir).with(path).and_return(true)
						expect(Box).to receive(:pwd_id).and_return(id)
						expect(stdout).to receive(:puts).with(id)
						subject
					}
				end
			end

		end
	end
end