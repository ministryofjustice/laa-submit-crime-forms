module TaskList
  class StatusTag < BaseRenderer
    attr_reader :status

    DEFAULT_CLASSES = %w[govuk-tag app-task-list__tag].freeze

    GRAY_TAG = 'govuk-tag--grey'.freeze
    STATUSES = {
      TaskStatus::COMPLETED => nil,
      TaskStatus::IN_PROGRESS => 'govuk-tag--blue',
      TaskStatus::NOT_STARTED => GRAY_TAG,
      TaskStatus::UNREACHABLE => GRAY_TAG,
      TaskStatus::NOT_APPLICABLE => GRAY_TAG,
    }.freeze

    def initialize(application, name:, status:)
      super(application, name:)
      @status = status
    end

    def render
      tag.strong id: tag_id, class: tag_classes do
        t!("tasklist.status.#{status}")
      end
    end

    private

    def tag_classes
      DEFAULT_CLASSES | Array(STATUSES.fetch(status))
    end
  end
end
