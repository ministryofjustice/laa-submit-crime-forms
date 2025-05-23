require 'rails_helper'

RSpec.describe ActiveOfficeCodeService do
  describe '.call' do
    subject { described_class.call(office_codes) }

    let(:office_codes) { %w[AAAAA BBBBB] }
    let(:status) { 200 }

    context 'when dealing with a single office code' do
      let(:office_codes) { ['AAAAA'] }

      context 'when the contract is active' do
        it 'returns the office code' do
          expect(subject).to eq office_codes
        end
      end
    end

    context 'when there is a local positive override' do
      let(:office_codes) { ['1A123B'] }

      before do
        Rails.configuration.x.office_code_overrides.active_office_codes = office_codes
      end

      it 'returns it as active' do
        expect(subject).to eq office_codes
      end
    end

    context 'when there is a local negative override' do
      let(:office_codes) { ['3B345C'] }

      before do
        Rails.configuration.x.office_code_overrides.inactive_office_codes = office_codes
      end

      it 'returns it as inactive' do
        expect(subject).to eq []
      end
    end
  end
end
