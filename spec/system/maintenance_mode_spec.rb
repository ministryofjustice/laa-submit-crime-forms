require 'rails_helper'

RSpec.describe 'Maintenance mode' do
  before do
    allow(Rails.env).to receive(:test?).and_return(false)
  end

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
      travel_to Time.find_zone('Europe/London').parse('2025-09-10 21:29:59') do
        visit nsm_applications_path
        expect(page).not_to have_content 'Sorry, the service is unavailable'
      end
    end

    it 'does not allow access after business hours' do
      travel_to Time.find_zone('Europe/London').parse('2025-09-10 21:30') do
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

    context 'OOH 2025' do
      it 'does not allow access on 25/12/25, 26/12/25, 01/01/26' do
        ['2025-12-25 10:00', '2025-12-26 14:00', '2026-01-01 00:01'].each do |date|
          travel_to Time.find_zone('Europe/London').parse(date) do
            visit nsm_applications_path
            expect(page).to have_content 'Sorry, the service is unavailable'
          end
        end
      end

      it 'bau allows access on 24/12/25, 29/12/25, 02/01/26' do
        ['2025-12-24 10:00', '2026-12-29 09:00', '2026-01-02 07:00'].each do |date|
          travel_to Time.find_zone('Europe/London').parse(date) do
            visit nsm_applications_path
            expect(page).not_to have_content 'Sorry, the service is unavailable'
          end
        end
      end
    end
  end
end
