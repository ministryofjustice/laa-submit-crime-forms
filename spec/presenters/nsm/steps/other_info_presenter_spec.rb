require 'rails_helper'

RSpec.describe Nsm::Tasks::OtherInfo, type: :system do
  subject { described_class.new(application:) }

  let(:application) { build(:claim, attributes) }
  let(:attributes) { { id:, viewed_steps: } }
  let(:id) { SecureRandom.uuid }
  let(:viewed_steps) { [] }

  describe '#path' do
    it { expect(subject.path).to eq("/non-standard-magistrates/applications/#{id}/steps/other_info") }
  end

  describe '#can_start?' do
    context 'cost summary page has not been visited' do
      it { expect(subject).not_to be_can_start }
    end

    context 'cost summary page has been visited' do
      before do
        viewed_steps << 'cost_summary'
      end

      it { expect(subject).to be_can_start }
    end
  end

  it_behaves_like 'a task with generic complete?', Nsm::Steps::OtherInfoForm
end
