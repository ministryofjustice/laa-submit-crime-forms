require 'rails_helper'

RSpec.describe Nsm::Tasks::SolicitorDeclaration, type: :system do
  subject { described_class.new(application:) }

  let(:application) { create(:claim, attributes) }
  let(:attributes) { { id: } }
  let(:id) { SecureRandom.uuid }

  describe '#path' do
    it { expect(subject.path).to eq("/applications/#{id}/steps/solicitor_declaration") }
  end

  it_behaves_like 'a task with generic complete?', Nsm::Steps::SolicitorDeclarationForm

  describe '#status and its enabled? flag' do
    context 'when status is NOT_APPLICABLE' do
      it 'is disabled' do
        allow(subject).to receive(:not_applicable?).and_return(true)

        expect(subject.status).not_to be_enabled
        expect(subject.status).to eq(TaskStatus::NOT_APPLICABLE)
      end
    end

    context 'when status is UNREACHABLE' do
      it 'is disabled' do
        allow(subject).to receive_messages(not_applicable?: false, can_start?: false)

        expect(subject.status).not_to be_enabled
        expect(subject.status).to eq(TaskStatus::UNREACHABLE)
      end
    end

    context 'when status is NOT_STARTED' do
      it 'is disabled' do
        allow(subject).to receive_messages(not_applicable?: false, can_start?: true, in_progress?: false)

        expect(subject.status).not_to be_enabled
        expect(subject.status).to eq(TaskStatus::NOT_STARTED)
      end
    end

    context 'when status is COMPLETED' do
      it 'is disabled' do
        allow(subject).to receive_messages(not_applicable?: false, can_start?: true, in_progress?: true,
                                           completed?: true)

        expect(subject.status).not_to be_enabled
        expect(subject.status).to eq(TaskStatus::COMPLETED)
      end
    end

    context 'when status is IN_PROGRESS' do
      it 'is disabled' do
        allow(subject).to receive_messages(not_applicable?: false, can_start?: true, in_progress?: true,
                                           completed?: false)

        expect(subject.status).not_to be_enabled
        expect(subject.status).to eq(TaskStatus::IN_PROGRESS)
      end
    end
  end
end
