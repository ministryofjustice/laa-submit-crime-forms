RSpec.shared_examples 'a show step controller' do
  describe '#show' do
    context 'when application is not found' do
      it 'redirects to the application not found error page' do
        get :show, params: { id: '12345' }
        expect(response).to redirect_to(controller.laa_msf.application_not_found_errors_path)
      end
    end

    context 'when application is found' do
      let(:existing_case) { Claim.create(office_code: 'AAA', defendants: [Defendant.new(main: true, full_name: 'Nigel', maat: '123')]) }

      it 'responds with HTTP success' do
        get :show, params: { id: existing_case }
        expect(response).to be_successful
      end
    end
  end
end
