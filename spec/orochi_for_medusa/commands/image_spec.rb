require 'spec_helper'
require 'orochi_for_medusa/commands/image'
include MedusaRestClient

module OrochiForMedusa::Commands
  describe Image do
    let(:cui) { Image.new(args, :stdin => stdin, :stdout => stdout, :stderr => stderr, :program_name => 'orochi-image') }
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
        #allow(cui).to receive(:ls)
        #allow(Record).to receive(:find_by_id)
      end

      describe "with invalid-id" do
        let(:args){ [id] }
        let(:id){ '0000000-001'}
        let(:obj){ double('obj') }
        it {
          expect(Record).to receive(:find_by_id_or_path).with(id).and_return(obj)
          #expect(stderr).to receive(:puts).with("Specify IMAGE-ID")
          expect { subject }.to raise_error(RuntimeError)
        }
      end

      describe "with image-id with --geo" do
        let(:args){ ['--geo', id] }
        let(:id){ '0000000-002'}
        let(:obj){ double('obj', :name => "example.png") }
        it {
          expect(obj).to receive(:kind_of?).with(AttachmentFile).and_return(true)
          expect(cui).not_to receive(:download_file).with(obj)
          expect(obj).to receive(:dump_geofile).with("example.geo").and_return(true)
          expect(obj).not_to receive(:to_json)
          expect(Record).to receive(:find_by_id_or_path).with(id).and_return(obj)
          subject
        }
      end

      
      describe "with image-id with --json" do
        let(:args){ ['--json', id] }
        let(:id){ '0000000-002'}
        let(:obj){ double('obj', :name => "example.png") }
        it {
          expect(obj).to receive(:kind_of?).with(AttachmentFile).and_return(true)
          expect(cui).not_to receive(:download_file).with(obj)
          expect(obj).not_to receive(:dump_geofile).with("example.geo")
          expect(obj).to receive(:to_json).and_return(true)
          expect(Record).to receive(:find_by_id_or_path).with(id).and_return(obj)
          subject
        }
      end      

      describe "with image-id without --geo and --json" do
        let(:args){ [id] }
        let(:id){ '0000000-002'}
        let(:obj){ double('obj', :name => 'example.png', :original_path => "/stone/system/attachment_files/0006/7796/20210809-1835.png?1628565726") }
        it {
          expect(obj).to receive(:kind_of?).with(AttachmentFile).and_return(true)
          expect(obj).not_to receive(:dump_geofile).with("example.geo")
          expect(cui).to receive(:download_file).with(obj)
          expect(Record).to receive(:find_by_id_or_path).with(id).and_return(obj)
          subject
        }
      end

      describe "without id" do
        let(:args){ [] }
        let(:id){ '0000000-001'}
        it {
          expect { subject }.to raise_error(RuntimeError)
        }
      end
      describe "download_file" do
        subject { cui.download_file(obj) }
        let(:obj){ double('obj', :name => 'example.png', :original_path => "/stone/system/attachment_files/0006/7796/20210809-1835.png?1628565726") }     
        let(:file){ double('file') }
        it {
            allow(File).to receive(:open).with(obj.name, "wb").and_return(file)
            subject
        }

      end
    end
  end
end