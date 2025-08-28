require 'rails_helper'
RSpec.describe ActiveOfficeCodeService do
  describe '.call' do
    subject { described_class.call(office_codes) }

    let(:office_codes) { %w[AAAAA BBBBB] }
    let(:status) { 200 }
    let(:office_code_a_stub) do
      stub_request(:head, 'https://provider-api.example.com/provider-offices/AAAAA/schedules?areaOfLaw=CRIME%20LOWER')
        .to_return(status:)
    end

    let(:office_code_b_stub) do
      stub_request(:head, 'https://provider-api.example.com/provider-offices/BBBBB/schedules?areaOfLaw=CRIME%20LOWER')
        .to_return(status:)
    end

    before do
      allow(FeatureFlags).to receive(:provider_api_login_check).and_return(double(:provider_api_login_check, enabled?: true))
      office_code_a_stub
      office_code_b_stub
      Rails.configuration.x.office_code_overrides.active_office_codes = office_codes
    end

    context 'when the login check is disabled' do
      before do
        allow(FeatureFlags).to receive(:provider_api_login_check).and_return(double(:provider_api_login_check, enabled?: false))
        office_code_a_stub
        office_code_b_stub
      end

      it 'does not call the API and allows access' do
        expect(subject).to eq(office_codes)
        expect(office_code_a_stub).not_to have_been_requested
        expect(office_code_b_stub).not_to have_been_requested
      end
    end

    it 'calls the API for each office code' do
      subject
      expect(office_code_a_stub).to have_been_requested
      expect(office_code_b_stub).to have_been_requested
    end

    context 'when dealing with a single office code' do
      let(:office_codes) { ['AAAAA'] }
      let(:url) { "/provider-offices/#{office_codes.first}/schedules?areaOfLaw=CRIME%20LOWER" }

      context 'when the contract is active' do
        it 'returns the office code' do
          expect(subject).to eq office_codes
        end
      end

      context 'when there is no active contract but there was before' do
        let(:status) { 204 }

        it 'removes the office code from the result' do
          expect(subject).to eq []
        end
      end

      context 'when there is an error with the HTTP request' do
        let(:status) { 500 }

        it 'fallsback to active office code list' do
          expect(subject).to eq(office_codes)
        end
      end
    end

    context 'when there is a local positive override' do
      let(:office_codes) { ['1A123B'] }

      before do
        allow(FeatureFlags).to receive(:provider_api_login_check).and_return(double(:provider_api_login_check, enabled?: false))
        Rails.configuration.x.office_code_overrides.active_office_codes = office_codes
      end

      it 'returns it as active' do
        expect(subject).to eq office_codes
      end
    end

    context 'when there is a local negative override' do
      let(:office_codes) { ['3B345C'] }

      context 'when PDA is disabled' do
        before do
          allow(FeatureFlags).to receive(:provider_api_login_check).and_return(double(:provider_api_login_check, enabled?: false))
        end

        context 'with local negative override' do
          before do
            Rails.configuration.x.office_code_overrides.inactive_office_codes = office_codes
          end

          it 'returns it as inactive' do
            expect(subject).to eq []
          end
        end

        context 'with no override' do
          before do
            Rails.configuration.x.office_code_overrides.inactive_office_codes = []
            Rails.configuration.x.office_code_overrides.active_office_codes = []
          end

          it 'returns it as inactive' do
            expect(subject).to eq []
          end
        end
      end
    end
  end
end
