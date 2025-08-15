require 'rails_helper'

RSpec.describe Silas::SilasProvider do
  let(:mock_request) { double('request') }
  let(:mock_strategy) { double('strategy', request: mock_request) }
  let(:provider) { described_class.new(mock_strategy) }

  describe '#initialize' do
    it 'stores the strategy' do
      expect(provider.instance_variable_get(:@strategy)).to eq(mock_strategy)
    end
  end

  describe '#tenant_id' do
    it 'returns ENTRA_TENANT_ID from environment' do
      allow(ENV).to receive(:fetch).with('ENTRA_TENANT_ID', nil).and_return('test-tenant-id')

      expect(provider.tenant_id).to eq('test-tenant-id')
    end
  end

  describe '#client_id' do
    it 'returns ENTRA_CLIENT_ID from environment' do
      allow(ENV).to receive(:fetch).with('ENTRA_CLIENT_ID', nil).and_return('test-client-id')

      expect(provider.client_id).to eq('test-client-id')
    end
  end

  describe '#client_secret' do
    it 'returns ENTRA_CLIENT_SECRET from environment' do
      allow(ENV).to receive(:fetch).with('ENTRA_CLIENT_SECRET', nil).and_return('test-client-secret')

      expect(provider.client_secret).to eq('test-client-secret')
    end
  end

  describe '#authorize_params' do
    context 'when strategy has no request' do
      let(:mock_strategy) { double('strategy', request: nil) }

      it 'returns default params with prompt none' do
        expect(provider.authorize_params).to eq({ prompt: 'select_account' })
      end
    end

    context 'when strategy has request' do
      let(:mock_params) { {} }

      before do
        allow(mock_request).to receive_messages(params: mock_params)
      end

      it 'returns default params when no prompt or login_hint' do
        expect(provider.authorize_params).to eq({ prompt: 'select_account' })
      end

      it 'uses prompt from request params when provided' do
        mock_params[:prompt] = 'none'

        expect(provider.authorize_params).to eq({ prompt: 'none' })
      end
    end
  end

  describe '#certificate_path' do
    let(:cert_path) { Rails.root.join('tmp', 'omniauth-cert.p12') }

    it 'returns existing cert path if file exists' do
      allow(File).to receive(:exist?).with(cert_path).and_return(true)

      expect(provider.send(:certificate_path)).to eq(cert_path)
    end

    it 'returns nil when no certificate data in environment' do
      allow(File).to receive(:exist?).with(cert_path).and_return(false)
      allow(ENV).to receive(:fetch).with('ENTRA_CERTIFICATE_DATA', nil).and_return(nil)

      expect(provider.send(:certificate_path)).to be_nil
    end

    it 'returns nil when certificate data is blank' do
      allow(File).to receive(:exist?).with(cert_path).and_return(false)
      allow(ENV).to receive(:fetch).with('ENTRA_CERTIFICATE_DATA', nil).and_return('')

      expect(provider.send(:certificate_path)).to be_nil
    end

    it 'creates and returns cert file when certificate data exists' do
      cert_data = 'fake-cert-data'
      encoded_data = Base64.strict_encode64(cert_data)

      allow(File).to receive(:exist?).and_return(false)
      allow(ENV).to receive(:fetch).with('ENTRA_CERTIFICATE_DATA', nil).and_return(encoded_data)
      allow(File).to receive(:binwrite).with(cert_path, cert_data)
      allow(File).to receive(:chmod).with(0o600, cert_path)
      allow(provider).to receive(:at_exit)

      expect(provider.send(:certificate_path)).to eq(cert_path)
      expect(File).to have_received(:binwrite).with(cert_path, cert_data)
      expect(File).to have_received(:chmod).with(0o600, cert_path)
    end
  end
end
