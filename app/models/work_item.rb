class WorkItem < ApplicationRecord
  belongs_to :claim

  include WorkItemCosts

  SORT_POSITION = {
    'travel' => 0,
    'waiting' => 1,
    'attendance_with_counsel' => 2,
    'attendance_without_counsel' => 3,
    'preparation' => 4,
    'advocacy' => 5
  }.freeze

  validates :id, exclusion: { in: [Nsm::StartPage::NEW_RECORD] }

  def as_json(*)
    super.merge(
      'work_type' => translated_work_type
    )
  end

  def translated_work_type
    translations(work_type, 'nsm.steps.check_answers.show.sections.work_items')
  end

  def sort_position
    SORT_POSITION[work_type.to_s]
  end

  # Cache the value if looking at a runtime
  def position
    super || (@position ||= claim.work_item_position(self))
  end

  def valid_work_type?
    return false if work_type.blank?

    WorkTypes::VALUES.detect { _1.to_s == work_type }.display?(application)
  end
end
