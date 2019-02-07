require 'spec_helper'
require 'orochi_for_medusa/commands/find'
include MedusaRestClient

module OrochiForMedusa::Commands
  describe Find do
    let(:cui) { Find.new(args, :stdin => stdin, :stdout => stdout, :stderr => stderr, :program_name => 'orochi-find') }
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


      describe "with id" do
        let(:args){ [id_1] }
        let(:id_1){ '0000000-001'}
        it {
          expect(cui).to receive(:find).with(id_1)
          subject
        }

      end
    end

    describe "find" do
      subject { cui.find keyword }
      let(:keyword){ 'hello'}
      let(:objs){ [obj_1] }
      let(:obj_1) { double("record", :name => 'dummy', :global_id => "0000-001").as_null_object }

      before do
        allow(Record).to receive(:find).and_return([])
      end
      it {
        subject
      }
    end

  end
end