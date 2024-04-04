require 'rails_helper'

RSpec.describe PriorAuthority::Steps::StartPageController, type: :controller do
  describe '#show' do
    let(:current_application) { create(:prior_authority_application) }

    before do
      allow(controller).to receive(:current_application).and_return(current_application)
      get :show, params: { application_id: current_application.id }
    end

    context 'a draft application' do
      let(:current_application) { create(:prior_authority_application, status: 'draft') }

      it 'creates an instance of TaskList presenter' do
        expect(controller.further_information_needed).to be_falsey
      end
    end

    context 'a sent back application' do
      let(:app_store_updated_at) { DateTime.current - 1.day }
      let(:current_application) { create(:prior_authority_application, :with_further_information, app_store_updated_at:) }

      it 'creates an instance of FurtherInformationTaskList presenter' do
        expect(controller.further_information_needed).to be_truthy
      end
    end

    context 'a sent back application with no further information' do
      let(:current_application) { create(:prior_authority_application, status: 'sent_back') }

      it 'creates an instance of TaskList presenter' do
        expect(controller.further_information_needed).to be_falsey
      end
    end
  end
end
