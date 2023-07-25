require 'rails_helper'

RSpec.describe Steps::SupportingEvidenceController, type: :controller do
  before do
    allow(controller).to receive(:current_application).and_return(current_application)
  end

  describe '#edit' do
    context 'when application is not found' do
      let(:current_application) { nil }

      it 'redirects to the application not found error page' do
        get :edit, params: { id: '12345' }
        expect(response).to redirect_to(controller.laa_msf.application_not_found_errors_path)
      end
    end

    context 'when application is found' do
      let(:current_application) { build(:claim) }
      let(:form) { instance_double(Steps::SupportingEvidenceForm) }

      before do
        allow(Steps::SupportingEvidenceForm).to receive(:build).and_return(form)
      end

      context 'when we navigate to the controller' do
        context 'and no files exist' do
          before do
            get :edit, params: { id: current_application }
          end

          it 'responds with HTTP Success' do
            expect(response).to be_successful
          end
        end

        context 'and files exist' do
          before do
            file = Rails.root.join('spec/support/assets/test.png')
            image = ActiveStorage::Blob.create_and_upload!(
              io: File.open(file, 'rb'),
              filename: 'test.png',
              content_type: 'image/png'
            )
            SupportingEvidence.create(claim: current_application, file: image)
          end

          it 'responds with HTTP Success' do
            get :edit, params: { id: current_application }

            expect(response).to be_successful
          end
        end
      end
    end
  end
end
