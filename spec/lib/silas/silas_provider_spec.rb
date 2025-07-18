# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Silas::SilasProvider do
  let(:strategy) { double('strategy') }
  let(:provider) { described_class.new(strategy) }

  around do |example|
    with_env({}) { example.run }
  end

  after do
    # Clean up certificate file after each test
    cert_path = Rails.root.join('tmp', 'omniauth-cert.p12')
    FileUtils.rm_f(cert_path)
  end

  def with_env(env_vars)
    old_values = {}
    env_vars.each do |key, value|
      old_values[key] = ENV.fetch(key, nil)
      ENV[key] = value
    end

    yield
  ensure
    old_values.each do |key, value|
      if value.nil?
        ENV.delete(key)
      else
        ENV[key] = value
      end
    end
  end

  describe '#tenant_id' do
    it 'returns the ENTRA_TENANT_ID environment variable' do
      with_env('ENTRA_TENANT_ID' => 'test-tenant-id') do
        expect(provider.tenant_id).to eq('test-tenant-id')
      end
    end

    it 'returns nil when ENTRA_TENANT_ID is not set' do
      expect(provider.tenant_id).to be_nil
    end
  end

  describe '#client_id' do
    it 'returns the ENTRA_CLIENT_ID environment variable' do
      with_env('ENTRA_CLIENT_ID' => 'test-client-id') do
        expect(provider.client_id).to eq('test-client-id')
      end
    end

    it 'returns nil when ENTRA_CLIENT_ID is not set' do
      expect(provider.client_id).to be_nil
    end
  end

  describe '#client_secret' do
    it 'returns the ENTRA_CLIENT_SECRET environment variable' do
      with_env('ENTRA_CLIENT_SECRET' => 'test-secret') do
        expect(provider.client_secret).to eq('test-secret')
      end
    end

    it 'returns nil when ENTRA_CLIENT_SECRET is not set' do
      expect(provider.client_secret).to be_nil
    end
  end

  describe '#authorize_params' do
    it 'returns the expected authorize parameters' do
      expect(provider.authorize_params).to eq({ prompt: 'select_account' })
    end
  end

  describe '#certificate_path' do
    context 'when client_secret is present' do
      it 'returns nil early' do
        with_env('ENTRA_CLIENT_SECRET' => 'test-secret') do
          expect(provider.certificate_path).to be_nil
        end
      end
    end

    context 'when client_secret is not present' do
      context 'and certificate file already exists' do
        before do
          cert_path = Rails.root.join('tmp', 'omniauth-cert.p12')
          File.write(cert_path, 'existing-cert-data')
        end

        it 'returns the existing certificate path' do
          cert_path = Rails.root.join('tmp', 'omniauth-cert.p12')
          expect(provider.certificate_path).to eq(cert_path)
        end
      end

      context 'and ENTRA_CERTIFICATE_DATA is blank' do
        it 'returns nil' do
          expect(provider.certificate_path).to be_nil
        end
      end

      context 'and ENTRA_CERTIFICATE_DATA is present' do
        let(:cert_data) { 'fake-certificate-data' }
        let(:encoded_cert_data) { Base64.strict_encode64(cert_data) }

        it 'creates and returns the certificate path' do
          with_env('ENTRA_CERTIFICATE_DATA' => encoded_cert_data) do
            cert_path = Rails.root.join('tmp', 'omniauth-cert.p12')
            expect(provider.certificate_path).to eq(cert_path)
          end
        end

        it 'writes the decoded certificate data to file' do
          with_env('ENTRA_CERTIFICATE_DATA' => encoded_cert_data) do
            provider.certificate_path
            cert_path = Rails.root.join('tmp', 'omniauth-cert.p12')
            expect(File.read(cert_path)).to eq(cert_data)
          end
        end

        it 'sets correct file permissions' do
          with_env('ENTRA_CERTIFICATE_DATA' => encoded_cert_data) do
            provider.certificate_path
            cert_path = Rails.root.join('tmp', 'omniauth-cert.p12')
            expect(File.stat(cert_path).mode & 0o777).to eq(0o600)
          end
        end
      end
    end
  end

  describe '#respond_to?' do
    context 'when checking for :certificate_path' do
      context 'and client_secret is present' do
        it 'returns false' do
          with_env('ENTRA_CLIENT_SECRET' => 'test-secret') do
            expect(provider.respond_to?(:certificate_path)).to be false
          end
        end
      end

      context 'and client_secret is nil' do
        it 'returns true' do
          expect(provider.respond_to?(:certificate_path)).to be true
        end
      end
    end

    context 'when checking for :client_secret' do
      it 'always returns true (client_secret method is always available)' do
        expect(provider.respond_to?(:client_secret)).to be true
      end
    end

    context 'when checking for other methods' do
      it 'delegates to super for existing methods' do
        expect(provider.respond_to?(:tenant_id)).to be true
        expect(provider.respond_to?(:client_id)).to be true
        expect(provider.respond_to?(:authorize_params)).to be true
      end

      it 'delegates to super for non-existing methods' do
        expect(provider.respond_to?(:non_existing_method)).to be false
      end
    end
  end

  describe 'authentication method precedence' do
    context 'when both client_secret and certificate_data are present' do
      it 'prioritizes client_secret and hides certificate_path' do
        with_env('ENTRA_CLIENT_SECRET' => 'test-secret', 'ENTRA_CERTIFICATE_DATA' => Base64.strict_encode64('fake-cert-data')) do
          expect(provider.respond_to?(:client_secret)).to be true
          expect(provider.respond_to?(:certificate_path)).to be false
          expect(provider.certificate_path).to be_nil
        end
      end
    end

    context 'when neither client_secret nor certificate_data is present' do
      it 'shows both methods' do
        expect(provider.respond_to?(:client_secret)).to be true
        expect(provider.respond_to?(:certificate_path)).to be true
      end
    end
  end

  describe 'edge cases' do
    context 'when ENTRA_CERTIFICATE_DATA is empty string' do
      it 'treats it as blank and returns nil' do
        with_env('ENTRA_CERTIFICATE_DATA' => '') do
          expect(provider.certificate_path).to be_nil
        end
      end
    end

    context 'when certificate_path method is called multiple times' do
      it 'returns the same path without recreating the file' do
        with_env('ENTRA_CERTIFICATE_DATA' => Base64.strict_encode64('fake-cert-data')) do
          path1 = provider.certificate_path
          path2 = provider.certificate_path
          expect(path1).to eq(path2)
        end
      end
    end
  end
end
