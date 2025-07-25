require 'rails_helper'

describe OmniAuth::Strategies::Silas do
  let(:strategy) { described_class.new(nil) }

  describe '#info' do
    let(:raw_info) do
      {
        'email' => 'test@example.com',
        'LAA_ACCOUNTS' => %w[1A123B 2A555X],
      }
    end

    before do
      allow(strategy).to receive(:raw_info).and_return(raw_info)
      strategy.instance_variable_set(:@raw_info, raw_info)
    end

    it 'returns the expected info hash' do
      expect(strategy.info).to include(
        email: 'test@example.com',
        roles: [],
        office_codes: %w[1A123B 2A555X]
      )
    end
  end

  describe 'private methods' do
    let(:raw_info) do
      {
        'email' => 'test@example.com',
        'LAA_ACCOUNTS' => office_codes_raw,
      }
    end

    before do
      allow(strategy).to receive(:raw_info).and_return(raw_info)
      strategy.instance_variable_set(:@raw_info, raw_info)
    end

    describe '#email' do
      let(:office_codes_raw) { [] }

      it 'returns the email from raw_info' do
        expect(strategy.send(:email)).to eq('test@example.com')
      end
    end

    describe '#roles' do
      let(:office_codes_raw) { [] }

      it 'returns an empty array' do
        expect(strategy.send(:roles)).to eq([])
      end
    end

    describe '#office_codes' do
      context 'when LAA_ACCOUNTS is a single string' do
        let(:office_codes_raw) { '1A123B' }

        it 'returns an array with the single office code' do
          expect(strategy.send(:office_codes)).to eq(['1A123B'])
        end
      end

      context 'when LAA_ACCOUNTS is an array' do
        let(:office_codes_raw) { %w[1A123B 2A555X 3B345C] }

        it 'returns the array of office codes' do
          expect(strategy.send(:office_codes)).to eq(%w[1A123B 2A555X 3B345C])
        end
      end

      context 'when LAA_ACCOUNTS is an empty array' do
        let(:office_codes_raw) { [] }

        it 'returns an empty array' do
          expect(strategy.send(:office_codes)).to eq([])
        end
      end
    end
  end

  describe '.mock_auth' do
    it 'returns the expected mock auth hash' do
      mock_auth = described_class.mock_auth

      expect(mock_auth).to be_a(OmniAuth::AuthHash)
      expect(mock_auth.provider).to eq('entra_id')
      expect(mock_auth.uid).to eq('test-user')
      expect(mock_auth.info.email).to eq('provider@example.com')
      expect(mock_auth.info.roles).to eq(['EFORMS'])
      expect(mock_auth.info.office_codes).to eq(%w[1A123B 2A555X 3B345C 4C567D])
    end
  end
end
