require 'rails_helper'

RSpec.describe PriorAuthority::Steps::ServiceCostForm do
  subject(:form) { described_class.new(arguments) }

  let(:application) do
    create(:prior_authority_application, :with_primary_quote_per_item, service_type: 'photocopying')
  end
  let(:arguments) do
    {
      record: application.primary_quote,
      application: application,
      prior_authority_granted: true,
      ordered_by_court: nil,
      related_to_post_mortem: nil,
      items: 'N/A',
      cost_per_item: '3',
      period: nil,
      cost_per_hour: nil,
      user_chosen_cost_type: nil,
    }
  end

  it 'renders an item-aware validation message for invalid per-item inputs' do
    expect(form).not_to be_valid
    expect(form.errors.of_kind?(:items, :not_a_number)).to be(true)

    messages = nil
    expect { messages = form.errors.full_messages }.not_to raise_error
    expect(messages.join(' ')).to include('The number of pages must be a number, like 25')
  end
end
