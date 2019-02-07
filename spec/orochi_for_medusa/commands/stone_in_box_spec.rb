require 'spec_helper'
require 'orochi_for_medusa/commands/stone_in_box'
include MedusaRestClient

module OrochiForMedusa::Commands
  describe StoneInBox do
    let(:cui) { StoneInBox.new(args, :stdin => stdin, :stdout => stdout, :stderr => stderr, :program_name => 'orochi-stone-in-box!') }
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
        let(:args){ [] }
        let(:id){ '0001'}

        it {
          expect(stdin).to receive(:gets).and_return(id, nil)
          expect(cui).to receive(:get_and_put).with(id)
          subject
        }
      end

      describe "with id" do
        let(:args){ [id] }
        let(:id){ '0001'}
        it {
          expect(cui).to receive(:get_and_put).with(id)
          subject
        }
      end

    end

    describe "get_and_put" do
      subject { cui.get_and_put id }
      let(:id){ '000-001' }
      let(:stone){ double('stone', :name => 'test-sample').as_null_object }
      let(:box){ double('box').as_null_object }
      before do 
        allow(Record).to receive(:find_by_id_or_path).with(id).and_return(stone)
        allow(Box).to receive(:new).and_return(box)
      end
      it {
        expect(box).to receive(:name=).with(stone.name)
        subject
      }
    end

  end
end