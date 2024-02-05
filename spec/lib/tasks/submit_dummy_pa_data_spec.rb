require 'rails_helper'

describe 'prior_authority:submit_dummy_data', type: :task do
  let(:dummy_client) { instance_double(SubmitToAppStore::HttpClient) }

  it 'makes an HTTP request' do
    expect(SubmitToAppStore::HttpClient).to receive(:new).and_return(dummy_client)
    expect(dummy_client).to receive(:post)
    Rake::Task['prior_authority:submit_dummy_data'].invoke
  end
end
