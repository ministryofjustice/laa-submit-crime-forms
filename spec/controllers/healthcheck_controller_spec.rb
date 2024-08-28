# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HealthcheckController do
  let(:parsed_body) { response.parsed_body.with_indifferent_access }

  describe 'ping' do
    before do
      get :ping
    end

    it 'renders successfully with 200' do
      expect(response).to have_http_status(:success)
    end

    it 'parsed body does not raise exception' do
      expect { parsed_body }.not_to raise_exception
    end

    it 'displays correct hash values' do
      expect(parsed_body.keys).to contain_exactly('branch_name', 'build_date', 'build_tag', 'commit_id')
    end
  end

  describe 'ready' do
    context 'when Clamby is up and running' do
      before { allow(Clamby).to receive(:safe?).and_return(true) }

      it 'renders successfully with 200' do
        get :ready
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when Clamby is not ready and returns nil' do
      before { allow(Clamby).to receive(:safe?).and_return(nil) }

      it 'returns a 503' do
        get :ready
        expect(response).to have_http_status(:service_unavailable)
      end
    end

    context 'when Clamby is not ready and raises an error' do
      before { allow(Clamby).to receive(:safe?).and_raise(Clamby::ClamscanClientError) }

      it 'returns a 503' do
        get :ready
        expect(response).to have_http_status(:service_unavailable)
      end
    end
  end
end
