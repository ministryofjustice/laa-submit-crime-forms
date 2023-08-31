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
            file = Rails.root.join('spec/fixtures/files/test.png')
            image = ActiveStorage::Blob.create_and_upload!(
              io: File.open(file, 'rb'),
              filename: 'test.png',
              content_type: 'image/png'
            )
            @file_upload = SupportingEvidence.create(claim: current_application, file: image)
          end

          it 'responds with HTTP Success' do
            get :edit, params: { id: current_application }

            expect(response).to be_successful
          end
        end
      end
    end
  end

  describe '#create' do
    context 'when a file is uploaded' do
      let(:current_application) { build(:claim) }

      before do
        request.env['CONTENT_TYPE'] = 'image/png'
        post :create, params: { id: '12345', documents: fixture_file_upload('test.png', 'image/png') }
      end

      after do
        FileUtils.rm SupportingEvidence.find(JSON.parse(response.body)['success']['evidence_id']).file_path
      end

      it 'uploads and returns a success' do
        expect(response).to be_successful
      end

      it 'returns the evidence_id' do
        expect(JSON.parse(response.body)['success']['evidence_id']).not_to be_empty
      end
    end

    context 'when an incorrect file is uploaded' do
      let(:current_application) { build(:claim) }

      before do
        post :create, params: { id: '12345', documents: fixture_file_upload('test.json', 'application/json') }
      end

      it 'returns a bad request' do
        expect(response).to be_bad_request
      end

      it 'returns an error message' do
        expect(JSON.parse(response.body)['error']['message']).to eq 'Incorrect file type provided'
      end
    end
  end

  describe '#destroy' do
    let(:current_application) { build(:claim) }
    let(:evidence) do
      SupportingEvidence.create(
        file_name: 'test.png',
        file_type: 'image/png',
        file_size: '2857',
        claim: current_application,
        file_path: Rails.root.join('spec/fixtures/files/12345').to_s
      )
    end

    context 'when there are files present' do
      before do
        FileUtils.cp Rails.root.join('spec/fixtures/files/test.png'), Rails.root.join('spec/fixtures/files/12345')
      end

      it 'deletes the file' do
        delete :destroy, params: { id: '12345', evidence_id: evidence.id }

        expect(response).to be_successful
      end
    end

    context 'when there are no files present' do
      it 'returns a 400' do
        delete :destroy, params: { id: '12345', evidence_id: SecureRandom.uuid }

        expect(response).to be_bad_request
      end
    end
  end
end
