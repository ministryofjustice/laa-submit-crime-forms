require 'rails_helper'

RSpec.describe PriorAuthority::Tasks::PrimaryQuote, type: :presenter do
  subject(:presenter) { described_class.new(application:) }

  let(:application) { create(:prior_authority_application) }

  describe '#path' do
    subject(:path) { presenter.path }

    it { is_expected.to eq("/prior-authority/applications/#{application.id}/steps/primary_quote") }
  end
end
