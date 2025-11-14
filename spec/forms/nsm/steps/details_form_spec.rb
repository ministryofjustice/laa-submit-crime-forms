require 'rails_helper'

RSpec.describe Nsm::Steps::DetailsForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      rep_order_date:,
    }
  end
  let(:rep_order_date) { nil }

  let(:application) { create(:claim, :youth_court_fee_applied) }

  before { subject.save! }

  context 'when rep order date is reset to before youth court runoff' do
    let(:rep_order_date) { Date.new(2024, 12, 5) }

    it 'resets youth court fields' do
      expect(application.reload.attributes).to include(
        'plea' => nil,
        'plea_category' => nil,
        'change_solicitor_date' => nil,
        'arrest_warrant_date' => nil,
        'include_youth_court_fee' => nil,
      )
    end
  end
end
