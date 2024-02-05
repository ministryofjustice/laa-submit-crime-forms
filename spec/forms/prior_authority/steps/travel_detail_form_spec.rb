require 'rails_helper'

RSpec.describe PriorAuthority::Steps::TravelDetailForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application: application,
      record: application,
      travel_cost_reason: travel_cost_reason,
      'travel_time(1i)': travel_hours,
      'travel_time(2i)': travel_minutes,
      travel_cost_per_hour: travel_cost_per_hour
    }
  end
  let(:travel_cost_reason) { '' }
  let(:travel_hours) { '' }
  let(:travel_minutes) { '' }
  let(:travel_cost_per_hour) { '' }

  describe '#validate' do
    let(:application) { instance_double(PriorAuthorityApplication, prison_law:, client_detained:) }
    let(:prison_law) { false }
    let(:client_detained) { false }

    context 'with valid values' do
      let(:travel_cost_reason) { 'Because I say so' }
      let(:travel_hours) { '12' }
      let(:travel_minutes) { '13' }
      let(:travel_cost_per_hour) { '15.2' }

      it { is_expected.to be_valid }
    end

    context 'with invalid values' do
      let(:travel_cost_reason) { '   ' }
      let(:travel_hours) { '' }
      let(:travel_minutes) { '61' }
      let(:travel_cost_per_hour) { '0' }

      it 'has appropriate validation errors' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:travel_cost_reason, :blank)).to be(true)
        expect(form.errors.messages[:travel_cost_reason]).to include(
          'Explain why there are travel costs if your client is not detained'
        )
        expect(form.errors.of_kind?(:travel_time, :blank_hours)).to be(true)
        expect(form.errors.messages[:travel_time]).to include('The number of hours must be a number')
      end

      context 'when travel costs do not require justification' do
        let(:prison_law) { true }

        it 'does not validate travel cost reason' do
          form.valid?
          expect(form.errors.of_kind?(:travel_cost_reason, :blank)).to be(false)
        end
      end
    end
  end

  describe '#travel_costs_require_justification?' do
    let(:application) { instance_double(PriorAuthorityApplication, prison_law:, client_detained:) }

    context 'when this is neither prison law nor client is detained' do
      let(:prison_law) { false }
      let(:client_detained) { false }

      it { is_expected.to be_travel_costs_require_justification }
    end

    context 'when this is not prison law but client is detained' do
      let(:prison_law) { false }
      let(:client_detained) { true }

      it { is_expected.not_to be_travel_costs_require_justification }
    end

    context 'when this is prison law but client is not detained' do
      let(:prison_law) { true }
      let(:client_detained) { false }

      it { is_expected.not_to be_travel_costs_require_justification }
    end

    context 'when this is prison law and client is detained' do
      let(:prison_law) { true }
      let(:client_detained) { true }

      it { is_expected.not_to be_travel_costs_require_justification }
    end
  end

  describe '#formatted_total_cost' do
    let(:application) { instance_double(PriorAuthorityApplication) }

    context 'when time and rate are provided' do
      let(:travel_hours) { '2' }
      let(:travel_minutes) { '30' }
      let(:travel_cost_per_hour) { '5' }

      it 'calculates an appropriate result' do
        expect(subject.formatted_total_cost).to eq '£12.50'
      end
    end

    context 'when time is not provided' do
      let(:travel_hours) { '' }
      let(:travel_minutes) { '' }
      let(:travel_cost_per_hour) { '5' }

      it 'returns 0' do
        expect(subject.formatted_total_cost).to eq '£0.00'
      end
    end

    context 'when rate is not provided' do
      let(:travel_hours) { '2' }
      let(:travel_minutes) { '1' }
      let(:travel_cost_per_hour) { '' }

      it 'returns 0' do
        expect(subject.formatted_total_cost).to eq '£0.00'
      end
    end
  end
end
