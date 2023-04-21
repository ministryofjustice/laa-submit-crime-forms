require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#title' do
    let(:title) { helper.content_for(:page_title) }

    before do
      helper.title(value)
    end

    context 'for a blank value' do
      let(:value) { '' }

      it { expect(title).to eq('Claim a non-standard magistrate fee - GOV.UK') }
    end

    context 'for a provided value' do
      let(:value) { 'Test page' }

      it { expect(title).to eq('Test page - Claim a non-standard magistrate fee - GOV.UK') }
    end
  end

  describe '#fallback_title' do
    before do
      allow(helper).to receive(:controller_name).and_return('my_controller')
      allow(helper).to receive(:action_name).and_return('an_action')

      # So we can simulate what would happen on production
      allow(
        Rails.application.config
      ).to receive(:consider_all_requests_local).and_return(false)
    end

    it 'calls #title with a blank value' do
      expect(helper).to receive(:title).with('')
      helper.fallback_title
    end

    context 'when consider_all_requests_local is true' do
      it 'raises an exception' do
        allow(Rails.application.config).to receive(:consider_all_requests_local).and_return(true)
        expect { helper.fallback_title }.to raise_error('page title missing: my_controller#an_action')
      end
    end
  end

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
