class WorkItem < ApplicationRecord
  belongs_to :claim

  include WorkItemCosts

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
    {
      'travel' => 0,
      'waiting' => 1,
      'attendance_with_counsel' => 2,
      'attendance_without_counsel' => 3,
      'preparation' => 4,
      'advocacy' => 5
    }[work_type.to_s]
  end

  def position
    1
  end
end
