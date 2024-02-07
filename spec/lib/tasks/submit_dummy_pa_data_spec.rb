require 'rails_helper'

describe 'prior_authority:submit_dummy_data', type: :task do
  let(:dummy_client) { instance_double(SubmitToAppStore::HttpClient) }

  before do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    allow(SubmitToAppStore::HttpClient).to receive(:new).and_return(dummy_client)
    allow(dummy_client).to receive(:post)
  end

  it 'makes an HTTP request' do
    Rake::Task['prior_authority:submit_dummy_data'].invoke
    expect(SubmitToAppStore::HttpClient).to have_received(:new)
    expect(dummy_client).to have_received(:post)
  end
end
