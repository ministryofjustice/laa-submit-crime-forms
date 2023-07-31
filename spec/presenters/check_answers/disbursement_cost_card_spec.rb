require 'rails_helper'

RSpec.describe CheckAnswers::DisbursementCostsCard do
  subject { described_class.new(claim) }

  let(:claim) { create(:claim, :complete) }

  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Disbursement costs')
    end
  end
end
