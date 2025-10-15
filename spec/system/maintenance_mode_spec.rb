require 'rails_helper'

RSpec.describe 'Maintenance mode' do
  after do
    ENV.delete('MAINTENANCE_MODE')
  end

  context 'when MAINTENANCE_MODE=true' do
    before { ENV['MAINTENANCE_MODE'] = 'true' }

    it 'does not allow access during business hours' do
      # Wednesday
      travel_to Time.find_zone('Europe/London').parse('2025-09-10 12:00') do
        visit nsm_applications_path
        expect(page).to have_content 'Sorry, the service is unavailable'
      end
    end

    it 'shows maintenance screen outside business hours' do
      travel_to Time.find_zone('Europe/London').parse('2025-09-10 03:00') do
        visit nsm_applications_path
        expect(page).to have_content 'Sorry, the service is unavailable'
      end
    end

    # Saturday
    it 'shows maintenance screen on weekends' do
      travel_to Time.find_zone('Europe/London').parse('2025-09-13 12:00') do
        visit nsm_applications_path
        expect(page).to have_content 'Sorry, the service is unavailable'
      end
    end
  end

  context 'when MAINTENANCE_MODE=false' do
    before { ENV['MAINTENANCE_MODE'] = 'false' }

    # Wednesday
    it 'allows access during business hours' do
      travel_to Time.find_zone('Europe/London').parse('2025-09-10 07:00') do
        visit nsm_applications_path
        expect(page).not_to have_content 'Sorry, the service is unavailable'
      end
    end

    it 'does not allow access just before business hours' do
      travel_to Time.find_zone('Europe/London').parse('2025-09-10 06:59:59') do
        visit nsm_applications_path
        expect(page).to have_content 'Sorry, the service is unavailable'
      end
    end

    it 'allows access just before the end of business hours' do
      travel_to Time.find_zone('Europe/London').parse('2025-09-10 18:59:59') do
        visit nsm_applications_path
        expect(page).not_to have_content 'Sorry, the service is unavailable'
      end
    end

    it 'does not allow access after business hours' do
      travel_to Time.find_zone('Europe/London').parse('2025-09-10 19:00') do
        visit nsm_applications_path
        expect(page).to have_content 'Sorry, the service is unavailable'
      end
    end

    # Saturday
    it 'does allow access on weekends' do
      travel_to Time.find_zone('Europe/London').parse('2025-09-13 12:00') do
        visit nsm_applications_path
        expect(page).not_to have_content 'Sorry, the service is unavailable'
      end
    end
  end
end
