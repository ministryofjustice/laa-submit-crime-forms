require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  render_views

  describe '#dev_login' do
    let(:provider) { create(:provider, :other, email: 'signed-in@example.com') }

    before do
      allow(FeatureFlags).to receive(:omniauth_test_mode)
        .and_return(instance_double(FeatureFlags::EnabledFeature, enabled?: true))
    end

    it 'lists generated test providers as login options' do
      generated_provider = create(
        :provider,
        :other,
        email: 'test-data-provider-1@example.com',
        office_codes: %w[T00001 T00002]
      )

      get :dev_login

      expect(response).to be_ok
      expect(response.body).to include(generated_provider.email)
      expect(response.body).to include('T00001, T00002')
      expect(response.body).to include("Log in as #{generated_provider.email}")
    end
  end
end
