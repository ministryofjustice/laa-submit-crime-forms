require 'rails_helper'

describe 'fixes:mismatched_references:find', type: :task do
  let(:matching_application) { create(:prior_authority_application, state: 'sent_back', laa_reference: 'LAA-123456') }
  let(:unmatched_application) { create(:prior_authority_application, state: 'sent_back', laa_reference: 'LAA-ABCDEF') }
  let(:matching_version) do
    {
      'application' => {
        'id' => matching_application.id,
        'state' => 'sent_back',
        'laa_reference' => matching_application.laa_reference
      }
    }
  end
  let(:unmatched_version) do
    {
      'application' => {
        'id' => unmatched_application.id,
        'state' =>  'sent_back',
        'laa_reference' => 'LAA-654321'
      }
    }
  end
  let(:client) { instance_double(AppStoreClient) }

  before do
    allow(AppStoreClient).to receive(:new).and_return(client)
    allow(client).to receive(:get).with(matching_application.id).and_return(matching_version)
    allow(client).to receive(:get).with(unmatched_application.id).and_return(unmatched_version)
    Rails.application.load_tasks if Rake::Task.tasks.empty?
  end

  after do
    Rake::Task['fixes:mismatched_references:find'].reenable
  end

  it 'prints out the correct information' do
    # rubocop:disable Layout/LineLength
    expected_output = "Submission ID: #{unmatched_application.id} App Store Reference: LAA-654321 Provider Reference: LAA-ABCDEF\n"
    # rubocop:enable Layout/LineLength
    expect { Rake::Task['fixes:mismatched_references:find'].execute }.to output(expected_output).to_stdout
  end
end
