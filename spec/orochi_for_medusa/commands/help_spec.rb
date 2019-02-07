require 'spec_helper'
require 'orochi_for_medusa/commands/help'
include MedusaRestClient

module OrochiForMedusa::Commands
  describe Help do
    let(:cui) { Help.new(args, :stdin => stdin, :stdout => stdout, :stderr => stderr, :program_name => 'orochi-help') }
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
        allow(cui).to receive(:show_help)
      end

    end

    # describe "get_and_put", :current => true do
    #   subject { cui.get_and_put obj }
    #   let(:obj) { double("record", :name => 'dummy').as_null_object }
    #   it {
    #     subject
    #   }
    # end

  end
end