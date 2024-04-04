RSpec.shared_examples 'a multi file upload controller' do |application:|
  let(:current_application) { instance_exec(&application) }

  before do
    allow(controller).to receive(:current_application).and_return(current_application)
  end

  describe '#create' do
    context 'when a file is uploaded' do
      before do
        request.env['CONTENT_TYPE'] = 'image/png'
        expect(Clamby).to receive(:safe?).and_return(true)
        post :create, params: { application_id: '12345', documents: fixture_file_upload('test.png', 'image/png') }
      end

      after do
        FileUtils.rm SupportingDocument.find(response.parsed_body['success']['evidence_id']).file_path
      end

      it 'uploads and returns a success' do
        expect(response).to be_successful
      end

      it 'returns the evidence_id' do
        expect(response.parsed_body['success']['evidence_id']).not_to be_empty
      end
    end

    context 'when a file fails to upload' do
      before do
        request.env['CONTENT_TYPE'] = 'image/png'
        post :create, params: { application_id: '12345', documents: nil }
      end

      it 'returns a bad request' do
        expect(response).to be_bad_request
      end

      it 'returns an error message' do
        expect(response.parsed_body['error']['message']).to eq 'Unable to upload file at this time'
      end
    end

    context 'when an incorrect file is uploaded' do
      let(:no_file_error_msg) do
        'The selected file must be a DOC, DOCX, XLSX, XLS, RTF, ODT, JPG, BMP, PNG, TIF or PDF'
      end

      before do
        post :create,
             params: { application_id: '12345', documents: fixture_file_upload('test.json', 'application/json') }
      end

      it 'returns a bad request' do
        expect(response).to be_bad_request
      end

      it 'returns an error message' do
        expect(response.parsed_body['error']['message']).to eq no_file_error_msg
      end
    end

    context 'when an vulnerable file is uploaded' do
      before do
        request.env['CONTENT_TYPE'] = 'image/png'
        expect(Clamby).to receive(:safe?).and_return(false)
        post :create, params: { application_id: '12345', documents: fixture_file_upload('test.png', 'image/png') }
      end

      it 'returns a bad request' do
        expect(response).to be_bad_request
      end

      it 'returns an error message' do
        expect(response.parsed_body['error']['message']).to eq('File potentially contains malware so cannot be ' \
                                                               'uploaded. Please contact your administrator')
      end
    end
  end
end
