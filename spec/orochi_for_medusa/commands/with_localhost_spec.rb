require 'spec_helper'
require 'orochi_for_medusa/commands/ditto'
require 'orochi_for_medusa/commands/url'

include MedusaRestClient

module OrochiForMedusa::Commands
  @allow_connect_localhost = false
  if @allow_connect_localhost
    describe Ditto do
      let(:cui) { Ditto.new(args, :stdin => stdin, :stdout => stdout, :stderr => stderr, :program_name => 'orochi-ditto') }
      let(:args){ [] }
      let(:stdout){ Output.new }
      let(:stderr){ Output.new }
      let(:stdin){ double('stdin').as_null_object }
      describe "with box-ID" do
        let(:box_1){ Box.create(:name => "deleteme-box-1" )}
        let(:box_copy){ Box.find_by_name("deleteme-box-1-copy")}
        let(:args){ [box_1.global_id] }
        before do
          subject
        end
        subject { cui.run }
        it { expect(box_copy).not_to be_nil }
        after do
          box_1.destroy
          box_copy[0].destroy
        end
      end

      describe "with stone-ID" do
        let(:stone_1){ Specimen.create(:name => "deleteme-stone-1" )}
        let(:stone_copy){ Specimen.find_by_name("deleteme-stone-1-copy")}
        let(:args){ [stone_1.global_id] }
        before do
          subject
        end
        subject { cui.run }
        it { expect(stone_copy).not_to be_nil }
        after do
          stone_1.destroy
          stone_copy[0].destroy
        end
      end

    end

    describe Url do
      describe "with url" do
        let(:cui) { Url.new(args, :stdin => stdin, :stdout => stdout, :stderr => stderr, :program_name => 'orochi-url') }
        let(:args){ ["http://localhost:3000/boxes/480"] }
        let(:stdout){ Output.new }
        let(:stderr){ Output.new }
        let(:stdin){ double('stdin').as_null_object }

        subject { cui.run }
        before do
          #cui.run
        end

        it {expect{ subject }.not_to raise_error }
      end

      describe "with id" do
        let(:cui) { Url.new(args, :stdin => stdin, :stdout => stdout, :stderr => stderr, :program_name => 'orochi-url') }
        #let(:cui) { Url.new(args, :program_name => 'orochi-url') }
        let(:args){ ["--id", "20150521110909-111103"] }
        #let(:args){ ["--id", "20091014092124228.hkitagawa"] }
        let(:stdout){ Output.new }
        let(:stderr){ Output.new }
        let(:stdin){ double('stdin').as_null_object }

        subject { cui.run }
        before do
          #cui.run
          #subject
        end

        it {expect{ subject }.not_to raise_error}
      end
    end
  end
end
