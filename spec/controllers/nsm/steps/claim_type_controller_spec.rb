require 'rails_helper'

RSpec.describe Nsm::Steps::ClaimTypeController, type: :controller do
  describe '#new' do 
    it 'returns a successful response with no params' do 
      get :new
      expect(response).to be_successful
    end
  end
end
