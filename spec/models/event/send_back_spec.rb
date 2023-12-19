require 'rails_helper'

RSpec.describe Event::SendBack do
  subject { described_class.build(claim:, previous_state:, comment:, current_user:) }

  let(:claim) { create(:submitted_claim, state:) }
  let(:state) { 'further_info' }
  let(:current_user) { create(:caseworker) }
  let(:previous_state) { 'submitted' }
  let(:comment) { 'decison was made' }

  it 'can build a new record' do
    expect(subject).to have_attributes(
      submitted_claim_id: claim.id,
      claim_version: 1,
      event_type: 'Event::SendBack',
      primary_user: current_user,
      details: {
        'field' => 'state',
        'from' => 'submitted',
        'to' => 'further_info',
        'comment' => 'decison was made'
      }
    )
  end

  it 'has a valid title' do
    expect(subject.title).to eq('Claim sent back to provider')
  end

  context 'when provider_requested' do
    let(:state) { 'provider_requested' }

    it 'has a valid title' do
      expect(subject.title).to eq('Claim sent back to provider')
    end
  end

  it 'body is set to comment' do
    expect(subject.body).to eq('decison was made')
  end
end
