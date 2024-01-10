require 'rails_helper'

RSpec.describe Tasks::BaseTask do
  subject { described_class.new(application:) }

  let(:details_klass) { Class.new(described_class) }
  let(:application) { double(:claim) }

  describe '.build' do
    context 'for a task with an implementation class' do
      # rubocop:disable RSpec/RemoveConst
      around do |spec|
        Tasks.const_set(:Details, details_klass)
        spec.run
        Tasks.send(:remove_const, :Details)
      end
      # rubocop:enable RSpec/RemoveConst

      it 'instantiate the implementation' do
        task = described_class.build(:details, application:)

        expect(task).to be_a(details_klass)
        expect(task.application).to eq(application)
      end
    end

    context 'for a task without an implementation class' do
      it 'instantiate the implementation' do
        task = described_class.build(:foobar_task, application:)

        expect(task).to be_a(described_class)
        expect(task.application).to eq(application)
      end
    end
  end

  describe '#fulfilled?' do
    before do
      allow_any_instance_of(
        details_klass
      ).to receive(:status).and_return(status)
    end

    context 'for a completed task' do
      let(:status) { TaskStatus::COMPLETED }

      it 'returns true' do
        expect(subject.fulfilled?(details_klass)).to be(true)
      end
    end

    context 'for an incomplete task' do
      let(:status) { TaskStatus::IN_PROGRESS }

      it 'returns false' do
        expect(subject.fulfilled?(details_klass)).to be(false)
      end
    end
  end

  describe '#path' do
    it { expect(subject.path).to eq('') }
  end

  describe '#not_applicable?' do
    it { expect(subject.not_applicable?).to be(true) }
  end

  describe '#default_url_options' do
    it { expect(subject.default_url_options).to eq(id: application) }
  end

  describe '#status' do
    before do
      allow(subject).to receive_messages(not_applicable?: not_applicable, can_start?: can_start, completed?: completed,
                                         in_progress?: in_progress)
    end

    let(:not_applicable) { false }
    let(:can_start) { false }
    let(:completed) { false }
    let(:in_progress) { false }

    context 'task is not applicable' do
      let(:not_applicable) { true }

      it { expect(subject.status).to eq(TaskStatus::NOT_APPLICABLE) }
    end

    context 'task can cannot start yet' do
      it { expect(subject.status).to eq(TaskStatus::UNREACHABLE) }
    end

    context 'task is completed' do
      let(:can_start) { true }
      let(:completed) { true }
      let(:in_progress) { true }

      it { expect(subject.status).to eq(TaskStatus::COMPLETED) }
    end

    context 'task is in progress' do
      let(:can_start) { true }
      let(:completed) { false }
      let(:in_progress) { true }

      it { expect(subject.status).to eq(TaskStatus::IN_PROGRESS) }
    end

    context 'task is not started' do
      let(:can_start) { true }
      let(:completed) { false }
      let(:in_progress) { false }

      it { expect(subject.status).to eq(TaskStatus::NOT_STARTED) }
    end
  end
end
