require 'rails_helper'

RSpec.describe CheckAnswers::DisbursementCostsCard do
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
            head_key: 'Accident Reconstruction Report',
            text: '£90.00'
          },
          {
            head_key: 'total',
            text: '£90.00',
            footer: true
          },
          {
            head_key: 'total_inc_vat',
            text: '£90.00'
          }
        ]
      )
    end
  end
end
