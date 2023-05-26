RSpec.shared_examples 'a task with generic can_start?' do |previous_task_class|
  describe '#can_start?' do
    let(:task) { instance_double(previous_task_class, status:) }

    before do
      allow(previous_task_class).to receive(:new).and_return(task)
    end

    context 'when case details are complete' do
      let(:status) { TaskStatus::COMPLETED }

      it { expect(subject).to be_can_start }
    end

    context 'when case details are not complete' do
      let(:status) { TaskStatus::IN_PROGRESS }

      it { expect(subject).not_to be_can_start }
    end
  end
end