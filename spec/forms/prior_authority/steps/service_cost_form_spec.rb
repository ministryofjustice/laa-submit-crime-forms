require 'rails_helper'

RSpec.describe PriorAuthority::Steps::ServiceCostForm do
  subject(:form) { described_class.new(arguments) }

  let(:service_type) { 'photocopying' }
  let(:application) { create(:prior_authority_application, :with_primary_quote_per_item, service_type:) }
  let(:record) { application.primary_quote }
  let(:arguments) do
    {
      record: record,
      application: application,
      prior_authority_granted: true,
      ordered_by_court: false,
      related_to_post_mortem: false,
      items: items,
      cost_per_item: cost_per_item,
      period: nil,
      cost_per_hour: nil,
      user_chosen_cost_type: nil,
    }
  end
  let(:items) { '5' }
  let(:cost_per_item) { '10' }

  describe 'per-item validation' do
    context 'when items is a decimal string' do
      let(:items) { '205.70' }

      it 'adds an item error without raising interpolation errors' do
        expect(form).not_to be_valid
        expect(form.errors[:items]).not_to be_empty
        expect { form.errors.full_messages }.not_to raise_error
      end
    end

    context 'when cost_per_item is not numeric' do
      let(:cost_per_item) { 'abc' }

      it 'adds an item-aware error without raising interpolation errors' do
        expect(form).not_to be_valid
        expect(form.errors[:cost_per_item]).not_to be_empty
        expect { form.errors.full_messages }.not_to raise_error
      end
    end

    context 'when items exceeds the integer limit' do
      let(:items) { NumericLimits::MAX_INTEGER + 1 }

      it 'is not valid' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:items, :less_than_or_equal_to)).to be(true)
        expect { form.errors.full_messages }.not_to raise_error
      end
    end

    context 'when cost_per_item exceeds the float limit' do
      let(:cost_per_item) { NumericLimits::MAX_FLOAT + 1 }

      it 'is not valid' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:cost_per_item, :less_than_or_equal_to)).to be(true)
        expect { form.errors.full_messages }.not_to raise_error
      end
    end
  end

  describe 'per-hour validation' do
    let(:service_type) { 'meteorologist' }
    let(:application) { create(:prior_authority_application, :with_primary_quote, service_type:) }
    let(:record) { application.primary_quote }
    let(:arguments) do
      {
        record: record,
        application: application,
        prior_authority_granted: true,
        ordered_by_court: false,
        related_to_post_mortem: false,
        'period(1)': period_hours,
        'period(2)': period_minutes,
        cost_per_hour: cost_per_hour,
        user_chosen_cost_type: 'per_hour',
      }
    end
    let(:period_hours) { '1' }
    let(:period_minutes) { '0' }
    let(:cost_per_hour) { '50' }

    context 'when cost_per_hour exceeds the float limit' do
      let(:cost_per_hour) { (NumericLimits::MAX_FLOAT + 1).to_s }

      it 'is not valid' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:cost_per_hour, :less_than_or_equal_to)).to be(true)
      end
    end

    context 'when period hours exceeds the integer limit' do
      let(:period_hours) { (NumericLimits::MAX_INTEGER + 1).to_s }

      it 'is not valid' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:period, :max_hours)).to be(true)
      end
    end
  end
end
