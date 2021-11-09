require 'spec_helper'
require 'tomograph/path'

RSpec.describe Tomograph::Path do
  subject { described_class.new('') }

  describe '#to_s' do
    before do
      # allow(Tomograph::Resources).to receive(:new).and_return(double(to_hash: []))
      # allow(Tomograph::Documentation).to receive(:new).and_return(double(to_hash: {'content' => [{'content' => {}}]}))
    end

    context 'if without query' do
      let(:path) { '/status/' }
      let(:stump) { '/status' }

      it 'no changes' do
        expect(described_class.new(path).to_s).to eq(stump)
      end
    end

    context 'if there is' do
      let(:path1) { '/status/{&search}{&page}' }
      let(:path2) { '/status/{?search,page}' }
      let(:stump) { '/status' }

      it 'delete query' do
        expect(described_class.new(path1).to_s).to eq(stump)
        expect(described_class.new(path2).to_s).to eq(stump)
      end

      context 'and a parameter' do
        let(:path1) { '/users/{id}/pokemons/{&search}{&page}' }
        let(:path2) { '/users/{id}/pokemons/{?search,page}' }
        let(:stump) { '/users/{id}/pokemons' }

        it 'delete query' do
          expect(described_class.new(path1).to_s).to eq(stump)
          expect(described_class.new(path2).to_s).to eq(stump)
        end
      end
    end
  end

  describe '#regexp' do
    it 'returns regexp' do
      expect(subject.regexp).to eq(/\A\z/)
    end
  end

  describe '#match' do
    it 'returns true' do
      expect(subject.match('')).to be_truthy
    end
  end
end
