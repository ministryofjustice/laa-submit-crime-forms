require 'rails_helper'

RSpec.describe 'Syncs' do
  let(:job) { instance_double(PullUpdates, perform: true) }

  before { allow(PullUpdates).to receive(:new).and_return(job) }

  it 'triggers a sync job' do
    get '/sync'

    expect(response).to have_http_status(:ok)
    expect(job).to have_received(:perform)
  end
end
