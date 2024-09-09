require 'rails_helper'

describe 'fixes:mismatched_references:fix', type: :task do
  let(:unmatched_application) do
    create(:prior_authority_application, id: '8db79c28-35fd-42ae-aef8-156fbe28631a', state: 'sent_back',
   laa_reference: 'LAA-ABCDEF')
  end
  let(:records) do
    [{ submission_id: unmatched_application.id, laa_reference: 'LAA-Xcoqqz' }]
  end

  before do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
  end

  after do
    Rake::Task['fixes:mismatched_references:fix'].reenable
  end

  it 'prints out the correct information' do
    # rubocop:disable Layout/LineLength
    expected_output = "Fixed LAA Reference for Submission: #{unmatched_application.id}. Old Reference: #{unmatched_application.laa_reference}, New Reference: #{records.first[:laa_reference]}\n"
    # rubocop:enable Layout/LineLength
    expect { Rake::Task['fixes:mismatched_references:fix'].execute }.to output(expected_output).to_stdout
  end
end
