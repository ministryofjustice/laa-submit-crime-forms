require 'rails_helper'

RSpec.describe About::FeedbackController do
  let(:message_delivery) { instance_double(FeedbackMailer::MessageDelivery) }

  describe '#feedback' do
    context 'index' do
      it 'has a 200 response code' do
        get :index
        expect(response).to have_http_status(:ok)
      end
    end

    context 'submitting' do
      before do
        allow(FeedbackMailer).to receive(:notify).and_return(message_delivery)
        allow(message_delivery).to receive(:deliver_later!)
        post :create, params: feedback_params
      end

      context 'valid feedback' do
        let(:feedback_params) do
          {
            feedback: {
              user_email: 'test@test.com',
              user_feedback: 'test',
              user_rating: 5
            }
          }
        end

        it 'redirects to root' do
          expect(response).to redirect_to(nsm_applications_path)
        end

        it 'flashes notice' do
          expect(flash.now[:notice]).to match(/Your feedback has been submitted/)
        end
      end

      context 'invalid feedback' do
        let(:feedback_params) do
          {
            feedback: {
              user_email: 'test@test.com',
              user_feedback: 'test'
            }
          }
        end

        it 'returns an error' do
          expect(response).to render_template('about/feedback/index')
        end
      end
    end
  end
end
