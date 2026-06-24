require 'rails_helper'
require 'request_store'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: OutboundRequestId.current
    end
  end

  before do
    routes.draw { get 'index' => 'anonymous#index' }
    allow_any_instance_of(ActionDispatch::Request).to receive(:request_id).and_return('rails-request-id')
  end

  after { RequestStore.clear! }

  it 'stores the Rails request id for downstream service calls' do
    get :index

    expect(response.body).to eq('rails-request-id')
  end
end
