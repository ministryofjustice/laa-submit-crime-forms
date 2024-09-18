require 'rails_helper'

RSpec.describe 'Maintenance mode' do
  context 'when maintenance mode is enabled via env var' do
    before do
      allow(ENV).to receive(:fetch).with('MAINTENANCE_MODE', 'false').and_return('true')
    end

    it 'shows the maintenance screen on all URLS' do
      visit nsm_applications_path
      expect(page).to have_content 'Sorry, the service is unavailable'
    end
  end
end
