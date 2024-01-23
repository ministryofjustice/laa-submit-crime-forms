require 'rails_helper'

RSpec.describe Nsm::Tasks::LettersCalls, type: :system do
  subject { described_class.new(application:) }

  let(:application) { create(:claim, attributes) }
  let(:attributes) { { id: } }
  let(:id) { SecureRandom.uuid }

  describe '#path' do
    it { expect(subject.path).to eq("/applications/#{id}/steps/letters_calls") }
  end

  it_behaves_like 'a task with generic can_start?', Nsm::Tasks::WorkItems
  it_behaves_like 'a task with generic complete?', Nsm::Steps::LettersCallsForm
end
