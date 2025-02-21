RSpec.shared_examples 'a task with generic can_start?' do |previous_task_class|
  describe '#can_start?' do
    let(:task) { instance_double(previous_task_class, current_status:) }

    before do
      allow(previous_task_class).to receive(:new).and_return(task)
    end

    context "when #{previous_task_class} are complete" do
      let(:current_status) { TaskStatus::COMPLETED }

      it { expect(subject).to be_can_start }
    end

    context "when #{previous_task_class} are not complete" do
      let(:current_status) { TaskStatus::IN_PROGRESS }

      it { expect(subject).not_to be_can_start }
    end
  end
end
