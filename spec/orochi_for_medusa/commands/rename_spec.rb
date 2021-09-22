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

      describe "with id and newname" do
        let(:args){ [id, newparam] }
        let(:id){ '0001'}
        let(:obj){ double('obj').as_null_object }
        let(:newparam){ "bra"}
        it {
          expect(Record).to receive(:find).with(id).and_return(obj)
          expect(obj).to receive(:name=).with(newparam)
          subject
        }
      end

      describe "with id and --description description" do
        let(:args){ [id, '--description', newparam] }
        let(:id){ '0001'}
        let(:newparam){ "brabra"}
        let(:obj){ double('obj').as_null_object }
        it {
          expect(Record).to receive(:find).with(id).and_return(obj)
          expect(obj).to receive(:description=).with(newparam)
          subject
        }
      end      

      describe "with id and --key key value" do
        let(:args){ [id, '--key', 'hoge', newparam] }
        let(:id){ '0001'}
        let(:newparam){ "brabra"}
        let(:obj){ double('obj').as_null_object }
        it {
          expect(Record).to receive(:find).with(id).and_return(obj)
          expect(obj).to receive(:hoge=).with(newparam)
          subject
        }
      end      
      #affine-matrix [4.91196e-01,9.81198e-02,2.58169e+03;-8.88352e-02,4.84811e-01,-1.27269e+03;2.42902e-08,-4.85341e-09,1.00000e+00]
      describe "with id and --key affine_matrix value" do
        let(:args){ [id, '--key', 'affine_matrix', newparam] }
        let(:id){ '0001'}
        let(:newparam){ "[4.91196e-01,9.81198e-02,2.58169e+03;-8.88352e-02,4.84811e-01,-1.27269e+03;2.42902e-08,-4.85341e-09,1.00000e+00]"}
        let(:obj){ double('obj').as_null_object }
        it {
          expect(Record).to receive(:find).with(id).and_return(obj)
          expect(obj).to receive(:affine_matrix_in_string=).with(newparam)
          subject
        }
      end      

    end

  end
end