require 'rails_helper'

RSpec.describe Event::NewVersion do
  subject { described_class.build(claim:) }

  let(:claim) { create(:submitted_claim) }

  it 'can build a new record' do
    expect(subject).to have_attributes(
      submitted_claim_id: claim.id,
      claim_version: 1,
      event_type: 'Event::NewVersion',
    )
  end

  it 'has a valid title' do
    expect(subject.title).to eq('New claim received')
  end
end
