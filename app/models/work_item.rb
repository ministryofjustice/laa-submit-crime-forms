class WorkItem < ApplicationRecord
  belongs_to :claim

  scope :changed_work_type, -> { where('work_type != allowed_work_type') }

  include WorkItemDetails

  WORK_TYPE_SUMMARY_ORDER = %w[
    travel
    waiting
    attendance_with_counsel
    attendance_without_counsel
    preparation
    advocacy
  ].freeze

  validates :id, exclusion: { in: [Nsm::StartPage::NEW_RECORD] }

  # Cache the value if looking at a runtime
  def position
    super || (@position ||= claim.work_item_position(self))
  end

  def valid_work_type?
    return false if work_type.blank?

    WorkTypes::VALUES.detect { _1.to_s == work_type }.display?(application)
  end

  def imported?
    self.created_at < current_application.import_date
  end
end
