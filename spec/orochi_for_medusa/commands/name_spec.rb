require 'spec_helper'
require 'orochi_for_medusa/commands/name'
include MedusaRestClient

module OrochiForMedusa::Commands
  describe Name do
    let(:cui) { Name.new(args, :stdin => stdin, :stdout => stdout, :stderr => stderr, :program_name => 'orochi-name') }
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


      describe "without id" do
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