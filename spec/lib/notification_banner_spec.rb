require 'rails_helper'

describe NotificationBanner do
  context 'when local development rails environment' do
    before do
      allow(Rails.env).to receive(:development?).and_return(true)
    end
  end
end
