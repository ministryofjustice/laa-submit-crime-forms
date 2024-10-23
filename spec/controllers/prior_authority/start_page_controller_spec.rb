require 'rails_helper'

RSpec.describe PriorAuthority::Steps::StartPageController, type: :controller do
  describe '#show' do
    let(:current_application) { create(:prior_authority_application) }

    before do
      allow(controller).to receive(:current_application).and_return(current_application)
      get :show, params: { application_id: current_application.id }
    end

    context 'a draft application' do
      let(:current_application) { create(:prior_authority_application, state: 'draft') }

      it 'creates an instance of TaskList presenter' do
        expect(controller.instance_values['tasklist']).to be_a PriorAuthority::StartPage::TaskList
      end
    end
  end
end
