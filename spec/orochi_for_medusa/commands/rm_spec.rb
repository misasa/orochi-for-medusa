require 'spec_helper'
require 'orochi_for_medusa/commands/rm'
include MedusaRestClient

module OrochiForMedusa::Commands
  describe Rm do
    let(:cui) { Rm.new(args, :stdin => stdin, :stdout => stdout, :stderr => stderr, :program_name => 'orochi-rm') }
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
          expect(cui).to receive(:get_and_rm).with(id)
          subject
        }
      end

      describe "with id" do
        let(:args){ [id] }
        let(:id){ '0001'}
        it {
          expect(cui).to receive(:get_and_rm).with(id)
          subject
        }
      end

    end

    describe "get_and_rm" do
      subject { cui.get_and_rm id }
      let(:id){ '0000-0001' }
      let(:obj){ double('record').as_null_object }
      before do
        cui.parse_options
        allow(Record).to receive(:find_by_id_or_path).with(id).and_return(obj)
      end
      context "without -f" do
        it {
          expect(stdin).to receive(:gets).and_return("yes")
          expect(obj).to receive(:destroy)
          subject
        }
      end

      context "with -f" do
        let(:args){ [ "-f" ]}
        it {
          expect(obj).to receive(:destroy)
          subject
        }
      end

    end

  end
end