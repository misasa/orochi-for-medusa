require 'spec_helper'
require 'orochi_for_medusa/commands/open'
include MedusaRestClient

module OrochiForMedusa::Commands
  describe Open do
    let(:cui) { Open.new(args, :stdin => stdin, :stdout => stdout, :stderr => stderr, :program_name => 'orochi-open') }
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
        let(:args){ [id] }
        let(:id){ '0001'}

        it {
          expect(cui).to receive(:opurl).with(id)
          subject
        }
      end


      describe "without id" do
        let(:args){ [] }
        let(:id){ '0001'}

        it {
          expect(stdin).to receive(:gets).and_return(id, nil)
          expect(cui).to receive(:opurl).with(id)
          subject
        }
      end
    end

    describe "opurl" do
      subject { cui.opurl id }
      let(:obj){ double("record", :id => 100).as_null_object }
      let(:id){ '0000-001' }
      before do
        cui.parse_options
        allow(obj).to receive(:kind_of?).with(Box).and_return(true)
        allow(Record).to receive(:find).with(id).and_return(obj)
        allow(cui).to receive(:platform).and_return("cygwin")
      end

      it {
        expect(cui).to receive(:system_execute).with(/^cygstart/)
        subject
      }
    end

  end
end