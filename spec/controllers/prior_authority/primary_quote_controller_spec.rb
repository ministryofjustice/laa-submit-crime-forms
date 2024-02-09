require 'rails_helper'

RSpec.describe PriorAuthority::Steps::PrimaryQuoteController, type: :controller do
  let(:application) { build(:prior_authority_application, primary_quote: quote) }
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
        put :update, params: { application_id: '12345', prior_authority_steps_primary_quote_form: { document: nil } }
      end

      it 'returns a successful response' do
        expect(response).to be_successful
      end
    end

    context 'when vulnerable file type is uploaded' do
      before do
        request.env['CONTENT_TYPE'] = 'image/png'
        allow(FileUpload::FileUploader).to receive(:scan_file).and_raise(PotentialMalwareError)
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
          .to eq('Incorrect file type provided')
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
        put :update,
            params: { application_id: '12345',
            prior_authority_steps_primary_quote_form:
            {
              document: fixture_file_upload('test.png', 'image/png')
            } }

        allow(controller).to receive(:update).and_raise(StandardError)
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
        expect(subject.send(:primary_quote)).to eq(quote)
      end
    end

    context 'custom primary quote service' do
      let(:quote) { build(:quote, :primary, :custom) }

      it 'returns a quote with non custom service type' do
        expect(subject.send(:primary_quote).service_type).to eq('random service')
      end
    end
  end
end
