require 'rails_helper'

RSpec.describe Event::Decision do
  subject { described_class.build(claim:, previous_state:, comment:, current_user:) }

  let(:claim) { create(:submitted_claim, state:) }
  let(:state) { 'granted' }
  let(:current_user) { create(:caseworker) }
  let(:previous_state) { 'submitted' }
  let(:comment) { 'decison was made' }

  it 'can build a new record' do
    expect(subject).to have_attributes(
      submitted_claim_id: claim.id,
      claim_version: 1,
      event_type: 'Event::Decision',
      primary_user: current_user,
      details: {
        'field' => 'state',
        'from' => 'submitted',
        'to' => 'granted',
        'comment' => 'decison was made'
      }
    )
  end

  it 'has a valid title' do
    expect(subject.title).to eq('Decision made to grant claim')
  end

  context 'when part granted' do
    let(:state) { 'part_grant' }

    it 'has a valid title' do
      expect(subject.title).to eq('Decision made to part grant claim')
    end
  end

  context 'when rejected' do
    let(:state) { 'rejected' }

    it 'has a valid title' do
      expect(subject.title).to eq('Decision made to reject claim')
    end
  end

  it 'body is set to comment' do
    expect(subject.body).to eq('decison was made')
  end
end
