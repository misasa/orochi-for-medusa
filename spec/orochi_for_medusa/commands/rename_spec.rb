require 'spec_helper'
require 'orochi_for_medusa/commands/rename'
include MedusaRestClient

module OrochiForMedusa::Commands
  describe Rename do
    let(:cui) { Rename.new(args, :stdin => stdin, :stdout => stdout, :stderr => stderr, :program_name => 'orochi-rename') }
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

    describe "rename" do
      subject { cui.rename id, param }
      let(:id){ "000-001" }
      let(:param){ "bra" }
      let(:obj){ double("record").as_null_object }
      before do
        allow(Record).to receive(:find).with(id).and_return(obj)
      end
      it {
        expect(obj).to receive(:name=).with(param)
        subject
      }
    end

    describe "execute" do   
      subject { cui.execute }
      before do
        cui.parse_options
      end


      describe "without id and newparam" do
        let(:args){ [id] }
        let(:id){ '0001'}

        it {
          expect{ subject }.to raise_error("specify id and newparam")
        }
      end

      describe "with id and newparam" do
        let(:args){ [id, newparam] }
        let(:id){ '0001'}
        let(:newparam){ "bra"}
        it {
          expect(cui).to receive(:rename).with(id, newparam)
          subject
        }
      end

    end

  end
end