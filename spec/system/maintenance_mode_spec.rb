require 'rails_helper'

RSpec.describe 'Maintenance mode' do
  context 'when maintenance mode is enabled' do
    let(:mode) { instance_double(FeatureFlags::EnabledFeature, enabled?: true) }

    before { allow(FeatureFlags).to receive(:maintenance_mode).and_return(mode) }

    it 'shows the maintenance screen on all URLS' do
      visit nsm_applications_path
      expect(page).to have_content 'Sorry, the service is unavailable'
    end
  end
end
