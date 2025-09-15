require 'rails_helper'
RSpec.describe 'Maintenance mode' do
  after do
    ENV.delete('MAINTENANCE_MODE')
  end

  context 'when MAINTENANCE_MODE=true' do
    before { ENV['MAINTENANCE_MODE'] = 'true' }

    it 'does not allow access during business hours' do
      travel_to Time.zone.parse('2025-09-10 12:00') do
        visit nsm_applications_path
        expect(page).to have_content 'Sorry, the service is unavailable'
      end
    end

    it 'shows maintenance screen outside business hours' do
      travel_to Time.zone.parse('2025-09-10 03:00') do
        visit nsm_applications_path
        expect(page).to have_content 'Sorry, the service is unavailable'
      end
    end

    it 'shows maintenance screen on weekends' do
      travel_to Time.zone.parse('2025-09-13 12:00') do
        visit nsm_applications_path
        expect(page).to have_content 'Sorry, the service is unavailable'
      end
    end
  end

  context 'when MAINTENANCE_MODE=false' do
    before { ENV['MAINTENANCE_MODE'] = 'false' }

    it 'allows access during business hours' do
      travel_to Time.zone.parse('2025-09-10 12:00') do
        visit nsm_applications_path
        expect(page).not_to have_content 'Sorry, the service is unavailable'
      end
    end

    it 'does not allow access outside business hours' do
      travel_to Time.zone.parse('2025-09-10 03:00') do
        visit nsm_applications_path
        expect(page).to have_content 'Sorry, the service is unavailable'
      end
    end

    it 'does not allow access on weekends' do
      travel_to Time.zone.parse('2025-09-13 12:00') do
        visit nsm_applications_path
        expect(page).to have_content 'Sorry, the service is unavailable'
      end
    end
  end
end
