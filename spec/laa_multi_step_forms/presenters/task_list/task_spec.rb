require 'rails_helper'

RSpec.describe TaskList::Task do
  subject { described_class.new(application, name:, task_statuses:) }

  let(:name) { :foobar_task }
  let(:application) { double }
  let(:task_statuses) { TaskList::TaskStatus.new }

  describe '#render' do
    before do
      # Ensure we don't rely on task locales, so we have predictable tests
      allow(subject).to receive(:t!).with('tasklist.task.foobar_task').and_return('Foo Bar Task Locale')

      allow(
        Tasks::BaseTask
      ).to receive(:build).with(
        name, application:, task_statuses:
      ).and_return(task_double)
    end

    let(:task_double) do
      instance_double(Tasks::BaseTask, status: status, path: '/steps/foobar')
    end

    context 'for an enabled task' do
      let(:status) { TaskStatus::IN_PROGRESS }

      it 'renders the expected task HTML element' do
        expect(
          subject.render
        ).to eq(
          '<li class="govuk-task-list__item govuk-task-list__item--with-link">' \
          '<div class="app-task-list__task-name govuk-task-list__name-and-hint">' \
          '<a class="govuk-link govuk-task-list__link" href="/steps/foobar" aria-describedby="foobar_task-status">' \
          'Foo Bar Task Locale</a></div>' \
          '<div id="foobar_task-status" class="app-task-list__tag govuk-tag govuk-tag--light-blue">In progress</div>' \
          '</li>'
        )
      end
    end

    context 'for a disabled task' do
      let(:status) { TaskStatus::UNREACHABLE }

      it 'renders the expected task HTML element' do
        expect(
          subject.render
        ).to eq(
          '<li class="govuk-task-list__item govuk-task-list__item--with-link">' \
          '<div class="app-task-list__task-name govuk-task-list__name-and-hint">Foo Bar Task Locale</div>' \
          '<div id="foobar_task-status" class="app-task-list__tag">' \
          'Cannot start yet</div>' \
          '</li>'
        )
      end
    end
  end
end
