require 'rails_helper'

RSpec.describe PriorAuthority::Steps::ServiceCostForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      record:,
      application:,
      prior_authority_granted:,
      ordered_by_court:,
      related_to_post_mortem:,
      items:,
      cost_per_item:,
      period:,
      cost_per_hour:,
      user_chosen_cost_type:,
    }
  end

  let(:record) { build(:quote, :primary, prior_authority_application: application) }
  let(:application) do
    create(
      :prior_authority_application,
      service_type: service_type,
      prior_authority_granted: true,
      custom_service_name: custom_service_name
    )
  end
  let(:prior_authority_granted) { nil }
  let(:ordered_by_court) { nil }
  let(:related_to_post_mortem) { nil }
  let(:period) { nil }
  let(:cost_per_hour) { nil }
  let(:items) { '1' }
  let(:cost_per_item) { '10' }
  let(:service_type) { 'photocopying' }
  let(:custom_service_name) { service_type == 'custom' ? 'Custom service' : nil }
  let(:user_chosen_cost_type) do
    rule = PriorAuthority::ServiceTypeRule.build(PriorAuthority::QuoteServices.new(service_type.to_sym))

    rule.cost_type == :variable ? 'per_item' : nil
  end

  describe 'per-item validation safety' do
    it_behaves_like 'safe per-item quote validations'
  end

  describe 'item-aware validation messages across per-item services' do
    per_item_service_types = (PriorAuthority::QuoteServices::VALUES.map(&:value) + ['custom']).select do |candidate|
      rule = PriorAuthority::ServiceTypeRule.build(PriorAuthority::QuoteServices.new(candidate.to_sym))

      rule.cost_type.in?([:per_item, :variable])
    end

    per_item_service_types.each do |candidate|
      context "when the service type is #{candidate}" do
        let(:service_type) { candidate }
        let(:items) { 'abc' }
        let(:cost_per_item) { 'abc' }

        it 'renders both validation messages without interpolation errors' do
          expect(form).not_to be_valid

          messages = nil
          expect { messages = form.errors.full_messages }.not_to raise_error

          expect(messages.join(' ')).to include(form.item_type.pluralize)
          expect(messages.join(' ')).to include(
            I18n.t("laa_crime_forms_common.prior_authority.service_costs.items.#{form.cost_item_type}")
          )
        end
      end
    end
  end
end
