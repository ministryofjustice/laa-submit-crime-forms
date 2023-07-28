require 'rails_helper'

RSpec.describe CheckAnswers::DisbursementCostsCard do
  subject { described_class.new(claim) }

  let(:claim) { create(:claim, :complete) }

  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Disbursement costs')
    end
  end

  describe '#route_path' do
    it 'is correct route' do
      expect(subject.route_path).to eq('disbursements')
    end
  end
end
