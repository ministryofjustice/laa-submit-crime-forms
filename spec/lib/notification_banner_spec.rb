require 'rails_helper'

describe NotificationBanner do
  context 'when local development rails environment' do
    let(:config) { {} }

    before do
      allow(Rails.configuration.x.notification_banner)
        .to receive(:notification)
        .and_return(config)
    end

    context 'notification message for current env and time' do
      let(:config) do
        {
          message: 'This is a test 1',
          date_from: 1.day.ago.to_s,
          date_to: 1.day.since.to_s
        }
      end

      it 'correctly determines notification message' do
        expect(described_class.active_banner).to eq('This is a test 1')
      end
    end

    context 'when the notification is not for the current date time' do
      let(:config) do
        {
          message: 'This is a test 1',
          date_from: 2.days.ago.to_s,
          date_to: 1.day.ago.to_s
        }
      end

      it 'correctly returns no notification message' do
        expect(described_class.active_banner).to be_nil
      end
    end
  end
end
