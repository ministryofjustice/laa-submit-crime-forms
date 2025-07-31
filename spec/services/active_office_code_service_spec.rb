require 'rails_helper'
RSpec.describe ActiveOfficeCodeService do
  describe '.call' do
    subject { described_class.call(office_codes) }

    let(:office_codes) { %w[AAAAA BBBBB] }
    let(:status) { 200 }
    let(:office_code_a_stub) do
      stub_request(:get, 'https://provider-api.example.com/provider-office/AAAAA/schedules')
        .to_return(
          status: status,
          body: { schedules: [{ areaOfLaw: 'CRIME LOWER' }] }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end
    let(:office_code_b_stub) do
      stub_request(:get, 'https://provider-api.example.com/provider-office/BBBBB/schedules')
        .to_return(
          status: status,
          body: { schedules: [{ areaOfLaw: 'CRIME LOWER' }] }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    before do
      office_code_a_stub
      office_code_b_stub
    end

    it 'calls the API for each office code' do
      subject
      expect(office_code_a_stub).to have_been_requested
      expect(office_code_b_stub).to have_been_requested
    end

    context 'when dealing with a single office code' do
      let(:office_codes) { ['AAAAA'] }

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

        it 'raises an error' do
          expect { subject }.to raise_error(
            'Unexpected status code 500 when querying provider API endpoint provider-office/AAAAA/schedules'
          )
        end
      end

      context 'when the schedule has CRIME LOWER area of law' do
        let(:office_code_a_stub) do
          stub_request(:get, 'https://provider-api.example.com/provider-office/AAAAA/schedules')
            .to_return(
              status: 200,
              body: { schedules: [{ areaOfLaw: 'CRIME LOWER' }] }.to_json,
              headers: { 'Content-Type' => 'application/json' }
            )
        end

        it 'returns the office code as active' do
          expect(subject).to eq office_codes
        end
      end

      context 'when the schedule has FAMILY area of law' do
        let(:office_code_a_stub) do
          stub_request(:get, 'https://provider-api.example.com/provider-office/AAAAA/schedules')
            .to_return(
              status: 200,
              body: { schedules: [{ areaOfLaw: 'FAMILY' }] }.to_json,
              headers: { 'Content-Type' => 'application/json' }
            )
        end

        it 'removes the office code from the result' do
          expect(subject).to eq []
        end
      end

      context 'when schedules is nil' do
        let(:office_code_a_stub) do
          stub_request(:get, 'https://provider-api.example.com/provider-office/AAAAA/schedules')
            .to_return(
              status: 200,
              body: { schedules: nil }.to_json,
              headers: { 'Content-Type' => 'application/json' }
            )
        end

        it 'removes the office code from the result' do
          expect(subject).to eq []
        end
      end

      context 'when areaOfLaw is nil' do
        let(:office_code_a_stub) do
          stub_request(:get, 'https://provider-api.example.com/provider-office/AAAAA/schedules')
            .to_return(
              status: 200,
              body: { schedules: [{ areaOfLaw: nil }] }.to_json,
              headers: { 'Content-Type' => 'application/json' }
            )
        end

        it 'removes the office code from the result' do
          expect(subject).to eq []
        end
      end
    end

    context 'when there is a local positive override' do
      let(:office_codes) { ['1A123B'] }

      before do
        Rails.configuration.x.office_code_overrides.active_office_codes = office_codes
      end

      it 'returns it as active' do
        expect(subject).to eq office_codes
      end
    end

    context 'when there is a local negative override' do
      let(:office_codes) { ['3B345C'] }

      before do
        Rails.configuration.x.office_code_overrides.inactive_office_codes = office_codes
      end

      it 'returns it as inactive' do
        expect(subject).to eq []
      end
    end
  end
end
