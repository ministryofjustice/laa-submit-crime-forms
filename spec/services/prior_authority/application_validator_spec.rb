require 'rails_helper'

RSpec.describe PriorAuthority::ApplicationValidator do
  describe '.call' do
    let(:application) { create(:prior_authority_application, :full) }

    before do
      application.update!(alternative_quotes_still_to_add: false)
    end

    it 'returns nil when application is valid' do
      expect(described_class.new(application).call).to be_nil
    end
  end
end
