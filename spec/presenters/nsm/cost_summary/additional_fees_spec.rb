require 'rails_helper'

RSpec.describe Nsm::CostSummary::AdditionalFees do
  subject { described_class.new(claim) }

  let(:claim) do
    instance_double(Claim, firm_office:, totals:)
  end
  let(:firm_office) { build(:firm_office, :valid) }
  let(:totals) do
    {
      additional_fees: {
        youth_court_fee: {
          claimed_total_exc_vat: 598.59
        },
        total: {
          claimed_total_exc_vat: 598.59
        }
      }
    }
  end

  describe '#rows' do
    it 'generates additional fee rows' do
      expect(subject.rows).to eq(
        [
          [
            { classes: 'govuk-table__header', text: 'Youth court fee' },
            { classes: 'govuk-table__cell--numeric', text: '£598.59' }
          ]
        ]
      )
    end
  end
end
