class WorkItem < ApplicationRecord
  belongs_to :claim

  validates :id, exclusion: { in: [Nsm::StartPage::NEW_RECORD] }

  def as_json(*)
    super.merge(
      'work_type' => translated_work_type
    )
  end

  def translated_work_type
    translations(work_type, 'nsm.steps.check_answers.show.sections.work_items')
  end
end
