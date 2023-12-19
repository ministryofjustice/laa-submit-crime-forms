require 'rails_helper'

RSpec.describe Event::Note do
  subject { described_class.build(claim:, note:, current_user:) }

  let(:claim) { create(:submitted_claim) }
  let(:current_user) { create(:caseworker) }
  let(:note) { 'new note' }

  it 'can build a new record' do
    expect(subject).to have_attributes(
      submitted_claim_id: claim.id,
      claim_version: 1,
      event_type: 'Event::Note',
      primary_user: current_user,
      details: {
        'comment' => 'new note'
      }
    )
  end

  it 'has a valid title' do
    expect(subject.title).to eq('Caseworker note')
  end

  it 'body is set to comment' do
    expect(subject.body).to eq('new note')
  end
end
