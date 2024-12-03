require 'rails_helper'

RSpec.describe Nsm::Tasks::CheckAnswers, type: :system do
  subject { described_class.new(application:) }

  let(:application) { build(:claim, attributes) }
  let(:attributes) do
    {
      id:,
      viewed_steps:
    }
  end
  let(:id) { SecureRandom.uuid }
  let(:viewed_steps) { [] }

  describe '#path' do
    it { expect(subject.path).to eq("/non-standard-magistrates/applications/#{id}/steps/check_answers") }
  end

  describe '#not_applicable?' do
    it { expect(subject).not_to be_not_applicable }
  end

  describe '#completed?' do
    context 'check_answers is last page in the navigation stack' do
      let(:viewed_steps) { ['check_answers'] }

      it { expect(subject).not_to be_completed }
    end

    context 'check_answers is not in the navigation stack' do
      let(:viewed_steps) { ['apples'] }

      it { expect(subject).not_to be_completed }
    end

    context 'check_answers is not the last page in the navigation stack' do
      let(:viewed_steps) { %w[check_answers equality] }

      it { expect(subject).to be_completed }
    end
  end
end
