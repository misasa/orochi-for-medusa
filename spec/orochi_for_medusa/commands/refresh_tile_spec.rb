require 'spec_helper'
require 'orochi_for_medusa/commands/refresh_tile'
include MedusaRestClient

module OrochiForMedusa::Commands
  describe RefreshTile do
    let(:cui) { RefreshTile.new(args, :stdin => stdin, :stdout => stdout, :stderr => stderr, :program_name => 'orochi-refresh-tile') }
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
      let(:obj){ double("record").as_null_object }
      before do
        cui.parse_options
      end


      describe "without id" do
        let(:args){ [] }
        let(:id){ '0001'}

        it {
          expect{ subject }.to raise_error(RuntimeError, "specify surface-ID")
        }
      end


      describe "with id and without layer_name" do
        let(:args){ [id] }
        let(:id){ '0001'}
        let(:layer_name){'layer-12'}
        let(:layer_id){ 11 }
        let(:surface){ double('surface', name: 'surface-0', global_id: id, attributes: {"layers" => [[10,'layer-1'],[layer_id,layer_name]]}).as_null_object }
        it {
          expect(Record).to receive(:find).with(id).and_return(surface)
          expect(surface).to receive(:make_tiles)
          subject
        }
      end
      
      describe "with id and layer_name" do
        let(:args){ [id, 'layer-12'] }
        let(:id){ '0001'}
        let(:layer_name){'layer-12'}
        let(:layer_id){ 11 }
        let(:surface){ double('surface', name: 'surface-0', global_id: id, attributes: {"layers" => [[10,'layer-1'],[layer_id,layer_name]]}).as_null_object }
        it {
          expect(Record).to receive(:find).with(id).and_return(surface)
          expect(surface).to receive(:make_layer_tiles).with(layer_id)
          subject
        }
      end
    end

  end
end