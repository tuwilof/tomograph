require 'spec_helper'

RSpec.describe Tomograph::Request do
  describe '#find_responses' do
    let(:ok) { { 'status' => '200' } }

    subject do
      described_class.new([ok, { 'status' => '400' }])
    end

    it 'returns an array of responses' do
      expect(subject.find_responses(status: 200)).to eq([ok])
    end
  end
end
