require 'rails_helper'

RSpec.describe LaaMultiStepForms::ApplicationHelper, type: :helper do
  describe '#current_application' do
    it 'raises an error' do
      expect { helper.current_application }.to raise_error('implement this action, in subclasses')
    end
  end

  describe '#title' do
    let(:title) { helper.content_for(:page_title) }

    before do
      helper.title(value)
    end

    context 'for a blank value' do
      let(:value) { '' }

      it { expect(title).to eq("Claim a non-standard magistrates&#39; court payment - GOV.UK") }
    end

    context 'for a provided value' do
      let(:value) { 'Test page' }

      it { expect(title).to eq("Test page - Claim a non-standard magistrates&#39; court payment - GOV.UK") }
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

  describe '#app_environment' do
    context 'when ENV is set' do
      around do |spec|
        env = ENV.fetch('ENV', nil)
        ENV['ENV'] = 'test'
        spec.run
        ENV['ENV'] = env
      end

      it 'returns based on ENV variable' do
        expect(helper.app_environment).to eq('app-environment-test')
      end
    end

    context 'when ENV is not set' do
      it 'returns based with local' do
        expect(helper.app_environment).to eq('app-environment-local')
      end
    end
  end
end
