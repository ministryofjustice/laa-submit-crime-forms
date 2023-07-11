# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HealthcheckController do
  context 'index' do
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

  private

  def parsed_body
    response.parsed_body.with_indifferent_access
  end
end
