require 'rails_helper'

RSpec.describe Nsm::ClaimsController do
  context 'index' do
    let(:scope) { double(:scope, not: [instance_double(Claim)]) }

    before do
      allow(AppStoreListService).to receive(:reviewed).and_return(
        instance_double(SubmissionList, pagy: :pagy, rows: :rows)
      )
      get :index
    end

    it 'renders successfully with claims' do
      expect(response).to render_template(:index)
      expect(response).to be_successful
    end
  end

  context 'clone' do
    let(:claim) { create(:claim, :complete, :as_draft) }
    # Ignore fields that `dup` doesn't handle, as well as fields that won't get duplicated
    # We also have to ignore `viewed_steps` as we redirect to the start page after cloning
    let(:ignored_attrs) { %w[id created_at updated_at viewed_steps] }

    before do
      claim.save
    end

    it 'can clone an application' do
      expect(Claim.count).to eq(1)

      get :clone, params: { id: claim.id }

      expect(Claim.count).to eq(2)

      expected = Claim.first.attributes.except(*ignored_attrs)
      actual = Claim.second.attributes.except(*ignored_attrs)

      expect(expected).to eq(actual)
    end

    context 'when the app is in production' do
      before do
        allow(HostEnv).to receive(:env_name).and_return('production')
        Rails.application.reload_routes!
      end

      routes do
        ActionDispatch::Routing::RouteSet.new_with_config(Rails.application.config)
      end

      it 'returns a 404' do
        expect(get: "/non-standard-magistrates/claims/#{claim.id}/clone").not_to be_routable
      end
    end
  end
end
