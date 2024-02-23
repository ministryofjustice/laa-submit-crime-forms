require 'rails_helper'

RSpec.describe PriorAuthority::Steps::CheckAnswersController, type: :controller do
  before do
    allow(controller).to receive(:current_application).and_return(current_application)
  end

  describe '#edit' do
    context 'when file is not ready for viewing - invalid' do
      let(:current_application) { create(:prior_authority_application) }

      it 'redirects to the start page' do
        get :edit, params: { application_id: current_application.id }
        expect(response).to redirect_to(prior_authority_steps_start_page_path(current_application))
      end
    end

    context 'when file is not ready for viewing - valid' do
      let(:current_application) do
        create(
          :prior_authority_application,
          :full,
          :with_primary_quote,
          :with_complete_prison_law,
          :with_all_tasks_completed,
          :with_alternative_quotes
        )
      end

      it 'renders the page' do
        get :edit, params: { application_id: current_application.id }
        expect(response).to be_successful
      end
    end
  end
end
