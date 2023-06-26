require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe 'current_office_code' do
    before do
      allow(helper).to receive(:current_provider).and_return(provider)
    end

    context 'current_provider is not set' do
      let(:provider) { nil }

      it 'returns nil' do
        expect(helper.current_office_code).to be_nil
      end
    end

    context 'when selected_office_code is present' do
      let(:provider) { instance_double(Provider, selected_office_code: 'A1') }

      it 'returns the selected_office_code' do
        expect(helper.current_office_code).to eq('A1')
      end
    end

    context 'when no selected_office_code but office_codes are present' do
      let(:provider) { instance_double(Provider, selected_office_code: nil, office_codes: %w[A2 A3]) }

      it 'returns the first office code' do
        expect(helper.current_office_code).to eq('A2')
      end
    end

    context 'when no selected_office_code or office_codes are present' do
      let(:provider) { instance_double(Provider, selected_office_code: nil, office_codes: []) }

      it 'returns nil' do
        expect(helper.current_office_code).to be_nil
      end
    end
  end
end
