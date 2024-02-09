require 'rails_helper'

RSpec.describe TaskList::Section do
  subject(:section) { described_class.new(application, name:, tasks:, index:, task_statuses:) }

  let(:name) { :foobar_task }
  let(:tasks) { [:task_one, :task_two] }
  let(:index) { 1 }
  let(:task_statuses) { TaskList::TaskStatus.new }

  let(:application) { double }

  describe '#items' do
    it 'contains a collection of Task instances' do
      expect(section.items).to contain_exactly(TaskList::Task, TaskList::Task)
    end

    it 'has the proper attributes' do
      expect(section.items.map(&:name)).to eq(tasks)
    end

    context 'when task name is a proc' do
      let(:tasks) { [:task_one, ->(_app) { 'task.two' }] }

      it 'evaluates the proc to detmine teh task name' do
        expect(section.items.map(&:name)).to eq([:task_one, 'task.two'])
      end
    end
  end

  describe '#render' do
    before do
      # Ensure we don't rely on task locales, so we have predictable tests
      allow(section).to receive(:t!).with('tasklist.heading.foobar_task').and_return('Foo Bar Heading')

      # We test the Task separately, here we don't need to
      allow_any_instance_of(TaskList::Task).to receive(:render).and_return('[task_markup]')
    end

    it 'renders the expected section HTML element' do
      expect(
        section.render
      ).to eq(
        '<li>' \
        '<h2 class="moj-task-list__section"><span class="moj-task-list__section-number">1.</span>Foo Bar Heading</h2>' \
        '<ul class="moj-task-list__items">[task_markup][task_markup]</ul>' \
        '</li>'
      )
    end

    context 'has numbered headings' do
      let(:index) { 3 }

      it 'renders the expected section HTML element' do
        expect(
          section.render
        ).to match(%r{<span class="moj-task-list__section-number">3.</span>})
      end
    end

    context 'when index is nil' do
      let(:index) { nil }

      it 'renders without numbered headings' do
        expect(
          section.render
        ).to eq(
          '<li>' \
          '<h2 class="moj-task-list__section">Foo Bar Heading</h2>' \
          '<ul class="moj-task-list__items">[task_markup][task_markup]</ul>' \
          '</li>'
        )
      end
    end
  end
end
