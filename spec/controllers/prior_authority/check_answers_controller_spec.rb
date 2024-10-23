require 'rails_helper'

RSpec.describe PriorAuthority::Steps::CheckAnswersController, type: :controller do
  before do
    allow(controller).to receive(:current_application).and_return(current_application)
  end

  describe '#edit' do
    context 'when application has already been submitted' do
      let(:current_application) { create(:prior_authority_application, state: 'submitted') }

      it 'redirects to the overview page' do
        get :edit, params: { application_id: current_application.id }
        expect(response).to redirect_to(prior_authority_application_path(current_application))
      end
    end

    context 'when applicaiton is not ready for submission' do
      let(:current_application) { create(:prior_authority_application, state: 'draft') }

      it 'redirects to the overview page' do
        get :edit, params: { application_id: current_application.id }
        expect(response).to redirect_to(prior_authority_steps_start_page_path(current_application))
      end
    end

    context 'when application is ready for submittijg - valid' do
      let(:current_application) do
        create(
          :prior_authority_application,
          :full,
          :with_primary_quote,
          :with_complete_prison_law,
          :with_all_tasks_completed,
          :with_alternative_quotes,
          state: :draft,
        )
      end

      it 'renders the page' do
        get :edit, params: { application_id: current_application.id }
        expect(response).to be_successful
      end
    end
  end
end
