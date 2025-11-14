require 'rails_helper'

RSpec.describe Nsm::Steps::BoiDetailsController, type: :controller do
  let(:provider) { create(:provider) }
  let(:id) { '00000000-0000-0000-0000-000000000000' }

  context 'provider has multiple office codes' do
    before do
      provider.update!(office_codes: %w[1A123B 2A555X])
      allow(controller).to receive(:current_provider).and_return(provider)
    end

    it 'does not default office code if there are multiple' do
      get :edit, params: { id: }
      expect(controller.instance_variable_get(:@form_object).application.office_code).to be_nil
    end
  end

  context 'provider has one office code' do
    before do
      provider.update!(office_codes: %w[1A123B])
      allow(controller).to receive(:current_provider).and_return(provider)
    end

    it 'defaults office code' do
      get :edit, params: { id: }
      expect(controller.instance_variable_get(:@form_object).application.office_code).to eq '1A123B'
    end
  end
end
