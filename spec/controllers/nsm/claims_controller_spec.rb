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

  context 'create' do
    let(:provider) { instance_double(Provider, office_codes: ['1A123B'], multiple_offices?: false) }
    let(:claim) { instance_double(Claim, id: SecureRandom.uuid) }

    before do
      allow(Claim).to receive(:create!).and_return(claim)
      allow(controller).to receive(:current_provider).and_return(provider)
    end

    it 'create a new Claim application with the users office_code' do
      post :create
      expect(Claim).to have_received(:create!)
        .with(hash_including(office_code: '1A123B', submitter: provider))
    end

    it 'create a new Claim application with an laa reference' do
      post :create
      expect(Claim).to have_received(:create!).with(hash_including(:laa_reference))
    end

    it 'redirects to the edit claim type step' do
      post :create
      expect(response).to redirect_to(edit_nsm_steps_claim_type_path(claim.id))
    end

    it 'sets the office code' do
      post :create
      expect(Claim).to have_received(:create!).with(hash_including(office_code: '1A123B'))
    end

    context 'when the provider has multiple office codes' do
      let(:provider) { instance_double(Provider, office_codes: %w[1A123B CCCC], multiple_offices?: true) }

      it 'sets no office code' do
        post :create
        expect(Claim).to have_received(:create!).with(hash_including(office_code: nil))
      end
    end
  end

  context 'clone' do
    let(:claim) { create(:claim, :complete, :as_draft) }
    # Ignore fields that `dup` doesn't handle, as well as fields that won't get duplicated
    # We also have to ignore `viewed_steps` as we redirect to the start page after cloning
    let(:ignored_attrs) { %w[id created_at updated_at core_search_fields laa_reference viewed_steps] }

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

  context 'generate LAA reference' do
    it 'generates reference starting with: LAA- and ending in 6 alphanumeric' do
      expect(subject.send(:generate_laa_reference)).to match(/LAA-[A-Za-z0-9]+/)
    end

    context 'if LAA reference already exists' do
      before do
        allow(SecureRandom).to receive(:alphanumeric).and_return('AAAAAA', 'BBBBBB')
        expect(Claim).to receive(:exists?).with(laa_reference: 'LAA-AAAAAA').and_return(true)
        expect(Claim).to receive(:exists?).with(laa_reference: 'LAA-BBBBBB').and_return(false)
      end

      it 'generates unique ID' do
        expect(subject.send(:generate_laa_reference)).to eq('LAA-BBBBBB')
      end
    end
  end
end
