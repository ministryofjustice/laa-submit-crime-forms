class WorkItem < ApplicationRecord
  belongs_to :claim

  include WorkItemCosts

  WORK_TYPE_SUMMARY_ORDER = %w[
    travel
    waiting
    attendance_with_counsel
    attendance_without_counsel
    preparation
    advocacy
  ].freeze

  validates :id, exclusion: { in: [Nsm::StartPage::NEW_RECORD] }

  def as_json(*)
    super.merge(
      'work_type' => translated_work_type
    )
  end

  def translated_work_type(value: :original)
    translations(value == :assessed ? assessed_work_type : work_type, 'nsm.steps.check_answers.show.sections.work_items')
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
