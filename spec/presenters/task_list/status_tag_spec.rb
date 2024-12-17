require 'rails_helper'

RSpec.describe TaskList::StatusTag do
  subject(:status_tag) { described_class.new(application, name:, status:) }

  let(:name) { :foobar_task }
  let(:application) { double }

  describe '#render' do
    context 'with `completed` status' do
      let(:status) { TaskStatus::COMPLETED }

      it {
        expect(status_tag.render).to eq(
          '<div id="foobar_task-status" class="app-task-list__tag">Completed</div>'
        )
      }
    end

    context 'with `in_progress` status' do
      let(:status) { TaskStatus::IN_PROGRESS }

      it {
        expect(status_tag.render).to eq(
          '<div id="foobar_task-status" class="app-task-list__tag govuk-tag govuk-tag--light-blue">' \
          'In progress</div>'
        )
      }
    end

    context 'with `not_started` status' do
      let(:status) { TaskStatus::NOT_STARTED }

      it {
        expect(status_tag.render).to eq(
          '<div id="foobar_task-status" class="app-task-list__tag govuk-tag govuk-tag--blue">' \
          'Not yet started</div>'
        )
      }
    end

    context 'with `unreachable` status' do
      let(:status) { TaskStatus::UNREACHABLE }

      it {
        expect(status_tag.render).to eq(
          '<div id="foobar_task-status" class="app-task-list__tag">' \
          'Cannot start yet</div>'
        )
      }
    end

    context 'with `not_applicable` status' do
      let(:status) { TaskStatus::NOT_APPLICABLE }

      it {
        expect(status_tag.render).to eq(
          '<div id="foobar_task-status" class="app-task-list__tag govuk-tag govuk-tag--grey">' \
          'Not applicable</div>'
        )
      }
    end

    context 'with an unknown status' do
      let(:status) { :anything_else }

      it 'raises an exception' do
        expect { status_tag.render }.to raise_error(KeyError)
      end
    end
  end
end
