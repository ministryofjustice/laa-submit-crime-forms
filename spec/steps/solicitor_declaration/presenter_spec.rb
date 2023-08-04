require 'rails_helper'

RSpec.describe Tasks::SolicitorDeclaration, type: :system do
  subject { described_class.new(application:) }

  let(:application) { Claim.create(attributes) }
  let(:attributes) { { id: id, office_code: 'AAA' } }
  let(:id) { SecureRandom.uuid }

  describe '#path' do
    it { expect(subject.path).to eq("/applications/#{id}/steps/solicitor_declaration") }
  end

  it_behaves_like 'a task with generic complete?', Steps::SolicitorDeclarationForm

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
        allow(subject).to receive(:not_applicable?).and_return(false)
        allow(subject).to receive(:can_start?).and_return(false)

        expect(subject.status).not_to be_enabled
        expect(subject.status).to eq(TaskStatus::UNREACHABLE)
      end
    end

    context 'when status is NOT_STARTED' do
      it 'is disabled' do
        allow(subject).to receive(:not_applicable?).and_return(false)
        allow(subject).to receive(:can_start?).and_return(true)
        allow(subject).to receive(:in_progress?).and_return(false)

        expect(subject.status).not_to be_enabled
        expect(subject.status).to eq(TaskStatus::NOT_STARTED)
      end
    end

    context 'when status is COMPLETED' do
      it 'is disabled' do
        allow(subject).to receive(:not_applicable?).and_return(false)
        allow(subject).to receive(:can_start?).and_return(true)
        allow(subject).to receive(:in_progress?).and_return(true)
        allow(subject).to receive(:completed?).and_return(true)

        expect(subject.status).not_to be_enabled
        expect(subject.status).to eq(TaskStatus::COMPLETED)
      end
    end

    context 'when status is IN_PROGRESS' do
      it 'is disabled' do
        allow(subject).to receive(:not_applicable?).and_return(false)
        allow(subject).to receive(:can_start?).and_return(true)
        allow(subject).to receive(:in_progress?).and_return(true)
        allow(subject).to receive(:completed?).and_return(false)

        expect(subject.status).not_to be_enabled
        expect(subject.status).to eq(TaskStatus::IN_PROGRESS)
      end
    end
  end
end
