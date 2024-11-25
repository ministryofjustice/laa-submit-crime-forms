require 'rails_helper'

RSpec.describe AppStore::V1::Collection do
  subject { described_class.new(initial_array) }

  describe 'initialize' do
    context 'when there is nothing passed in' do
      let(:initial_array) { nil }

      it 'behaves like nothing was passed in' do
        expect(subject.length).to eq 0
      end
    end
  end

  describe 'order' do
    let(:initial_array) { %w[medium short very_long] }

    it 'sorts by passed in attribute' do
      expect(subject.order(:length)).to eq %w[short medium very_long]
    end

    it 'sorts by passed in attribute with ascending order' do
      expect(subject.order(length: :asc)).to eq %w[short medium very_long]
    end

    it 'sorts by passed in attribute with descending order' do
      expect(subject.order(length: :desc)).to eq %w[very_long medium short]
    end
  end
end
