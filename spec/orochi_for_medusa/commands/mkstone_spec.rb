require 'spec_helper'
require 'orochi_for_medusa/commands/mkstone'
include MedusaRestClient

module OrochiForMedusa::Commands
  describe Mkstone do
    let(:cui) { Mkstone.new(args, :stdin => stdin, :stdout => stdout, :stderr => stderr, :program_name => 'orochi-mkstone') }
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
        allow(cui).to receive(:ls)
      end


      describe "without id" do
        let(:args){ [name] }
        let(:name){ 'sample-test'}
        it {
          expect(cui).to receive(:mkstone).with(name)
          subject
        }
      end

    end

    describe "mkstone" do
      subject { cui.mkstone name }
      let(:name){ "new-sample"}
      let(:obj){ double("sample", :name => name, :global_id => "0003").as_null_object }
      before do
        allow(Specimen).to receive(:new).and_return(obj)
      end
      it {
        expect(obj).to receive(:name=).with(name)
        #expect(cui).to receive(:system_execute).with("tepra print #{obj.global_id},#{obj.name}")
          subject
      }
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
