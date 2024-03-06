require 'rails_helper'

RSpec.describe Nsm::CheckAnswers::DisbursementCostsCard do
  subject { described_class.new(claim) }

  let(:claim) { create(:claim, :one_other_disbursement) }

  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Disbursement costs')
    end
  end

  describe '#row_data' do
    it 'generates disbursement costs rows' do
      expect(subject.row_data).to eq(
        [
          {
            head_key: 'items',
            text: '<strong>Total per item</strong>'
          },
          {
            head_opts: { text: 'Accident Reconstruction Report' },
            text: '£90.00'
          },
          {
            head_key: 'total',
            text: '<strong>£90.00</strong>',
            footer: true
          },
          {
            head_key: 'total_inc_vat',
            text: '<strong>£90.00</strong>'
          }
        ]
      )
    end
  end
end
