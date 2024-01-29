require 'rails_helper'

RSpec.describe PriorAuthority::Tasks::PrimaryQuote, type: :presenter do
  subject(:presenter) { described_class.new(application:) }

  let(:application) { create(:prior_authority_application) }

  describe '#path' do
    subject(:path) { presenter.path }

    it { is_expected.to eq("/prior-authority/applications/#{application.id}/steps/primary_quote") }
  end

  describe '#completed?' do
    context 'when primary quote is completed' do
      before do
        create(:quote, primary: true, prior_authority_application: application)
      end

      it { is_expected.to be_completed }
    end

    context 'when primary quote is not completed' do
      it { is_expected.not_to be_completed }
    end
  end
end
