require 'rails_helper'

RSpec.describe PriorAuthority::Steps::PrimaryQuoteController, type: :controller do
  let(:application) { create(:prior_authority_application) }

  before do
    allow(controller).to receive(:current_application).and_return(application)
  end

  describe '#update' do
    context 'when there is a standard error' do
      let(:form_object) { instance_double(PriorAuthority::Steps::PrimaryQuoteForm) }

      before do
        allow(PriorAuthority::Steps::PrimaryQuoteForm).to receive(:new).and_return(form_object)
        allow(form_object).to receive(:save).and_raise(StandardError)
        allow(form_object).to receive_message_chain(:errors, :add)
      end

      it 're-shows the form with an error message' do
        expect(form_object).to receive_message_chain(:errors, :add)
        put :update, params: { application_id: '12345' }
        expect(response).to render_template(:edit)
      end

      it 'captures the error' do
        expect(Sentry).to receive(:capture_exception)
        put :update, params: { application_id: '12345' }
      end
    end
  end
end
