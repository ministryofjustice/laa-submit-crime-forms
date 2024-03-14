require 'rails_helper'

RSpec.describe Quote do
  subject { described_class.new(attributes) }

  describe '#additional_cost_value' do
    context 'for a primary quote' do
      let(:attributes) { { primary: true } }

      it 'calculates total_cost correctly' do
        expect(subject.additional_cost_value).to eq(0.00)
      end
    end

    context 'for an alternative quote' do
      let(:attributes) { { primary: false, additional_cost_total: 10 } }

      it 'calculates total_cost correctly' do
        expect(subject.additional_cost_value).to eq(10.00)
      end
    end
  end
end
