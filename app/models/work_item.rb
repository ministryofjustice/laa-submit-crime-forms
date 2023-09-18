class WorkItem < ApplicationRecord
  belongs_to :claim

  validates :id, exclusion: { in: [StartPage::NEW_RECORD] }

  def as_json(*)
    super.merge(
      'work_type' => translations(work_type, 'steps.check_answers.show.sections.work_items')
    )
  end
end
