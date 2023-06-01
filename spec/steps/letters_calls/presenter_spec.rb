require 'rails_helper'

RSpec.describe Tasks::LettersCalls, type: :system do
  subject { described_class.new(application:) }

  let(:application) { Claim.create(attributes) }
  let(:attributes) { { id: id, office_code: 'AAA' } }
  let(:id) { SecureRandom.uuid }

  describe '#path' do
    it { expect(subject.path).to eq("/applications/#{id}/steps/letters_calls") }
  end

  it_behaves_like 'a task with generic can_start?', Tasks::ReasonForClaim
  it_behaves_like 'a task with generic complete?', Steps::LettersCallsForm
end
