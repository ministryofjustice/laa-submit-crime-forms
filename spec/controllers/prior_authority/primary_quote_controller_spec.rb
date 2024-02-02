require 'rails_helper'

RSpec.describe PriorAuthority::Steps::PrimaryQuoteController, type: :controller do
  let(:application) { create(:prior_authority_application, primary_quote: quote) }
  let(:quote) { build(:quote, :primary) }

  before do
    allow(controller).to receive(:current_application).and_return(application)
  end

  describe '#update' do
    context 'when a file is uploaded' do
      before do
        request.env['CONTENT_TYPE'] = 'image/png'
        expect(Clamby).to receive(:safe?).and_return(true)
        put :update,
            params: { application_id: '12345',
            prior_authority_steps_primary_quote_form: {
              document: fixture_file_upload('test.png', 'image/png')
            } }
      end

      it 'returns a successful response' do
        expect(response).to be_successful
      end
    end

    context 'when no file is uploaded' do
      before do
        request.env['CONTENT_TYPE'] = 'image/png'
        put :update, params: { application_id: '12345', prior_authority_steps_primary_quote_form: {
          document: nil
        } }
      end

      context 'when there is already a file associated to quote' do
        it 'redirects back to form' do
          expect(response).to be_successful
        end
      end

      context 'when there is no file associated to quote' do
        let(:quote) { build(:quote, :primary, :no_document) }

        it 'redirects back to form' do
          expect(response).to redirect_to(edit_prior_authority_steps_primary_quote_path(application))
        end

        it 'generates flash error' do
          expect(flash[:alert])
            .to eq('Upload the primary quote')
        end
      end
    end

    context 'when vulnerable file type is uploaded' do
      before do
        request.env['CONTENT_TYPE'] = 'image/png'
        allow(controller).to receive(:upload_file).and_raise(FileUpload::FileUploader::PotentialMalwareError)
        put :update,
            params: { application_id: '12345',
            prior_authority_steps_primary_quote_form:
              {
                document: fixture_file_upload('test.png', 'image/png')
              } }
      end

      it 'redirects back to form' do
        expect(response).to redirect_to(edit_prior_authority_steps_primary_quote_path(application))
      end

      it 'generates flash error' do
        expect(flash[:alert])
          .to eq('File potentially contains malware so cannot be uploaded. Please contact your administrator')
      end
    end

    context 'when incorrect file type is uploaded' do
      before do
        request.env['CONTENT_TYPE'] = 'application/json'
        put :update,
            params: { application_id: '12345',
            prior_authority_steps_primary_quote_form:
            {
              document: fixture_file_upload('test.png', 'application/json')
            } }
      end

      it 'redirects back to form' do
        expect(response).to redirect_to(edit_prior_authority_steps_primary_quote_path(application))
      end

      it 'generates flash error' do
        expect(flash[:alert])
          .to eq('The selected file must be a DOC, DOCX, XLSX, XLS, RTF, ODT, JPG, BMP, PNG, TIF or PDF')
      end
    end

    context 'when file size too big' do
      before do
        request.env['CONTENT_TYPE'] = 'image/png'
        put :update,
            params: { application_id: '12345',
            prior_authority_steps_primary_quote_form:
            {
              document: fixture_file_upload('test_2.png', 'image/png')
            } }
      end

      it 'redirects back to form' do
        expect(response).to redirect_to(edit_prior_authority_steps_primary_quote_path(application))
      end

      it 'generates flash error' do
        expect(flash[:alert])
          .to eq('The selected file must be smaller than 10MB')
      end
    end

    context 'when there is a standard error' do
      before do
        request.env['CONTENT_TYPE'] = 'image/png'
        allow(controller).to receive(:upload_file).and_raise(StandardError)
        put :update,
            params: { application_id: '12345',
            prior_authority_steps_primary_quote_form:
            {
              document: fixture_file_upload('test.png', 'image/png')
            } }
      end

      it 'redirects back to form' do
        expect(response).to redirect_to(edit_prior_authority_steps_primary_quote_path(application))
      end

      it 'generates flash error' do
        expect(flash[:alert])
          .to eq('Unable to upload file at this time')
      end
    end
  end

  describe '#primary_quote' do
    context 'non custom primary quote service' do
      it 'returns a quote with non custom service type' do
        expect(subject.send(:record)).to eq(quote)
      end
    end
  end
end
