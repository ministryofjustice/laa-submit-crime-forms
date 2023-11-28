class Claim < ApplicationRecord
  belongs_to :submitter, class_name: 'Provider'
  belongs_to :firm_office, optional: true
  belongs_to :solicitor, optional: true
  has_many :defendants, -> { order(:position) }, dependent: :destroy, inverse_of: :claim
  has_one :main_defendant, -> { where(main: true) }, class_name: 'Defendant', dependent: nil, inverse_of: :claim
  has_many :work_items, -> { order(:completed_on, :work_type, :id) }, dependent: :destroy, inverse_of: :claim
  has_many :disbursements, lambda {
                             order(:disbursement_date, :disbursement_type, :id)
                           }, dependent: :destroy, inverse_of: :claim
  has_many :supporting_evidence, -> { order(:created_at, :file_name) }, dependent: :destroy, inverse_of: :claim

  scope :for, ->(provider) { where(office_code: provider.selected_office_code) }

  enum status: { draft: 'draft', submitted: 'completed', granted: 'granted', part_grant: 'part-granted',
                 review: 'review', further_info: 'further_info', provider_requested: 'provider_requested',
                 rejected: 'rejected' }

  def date
    rep_order_date || cntp_date
  end

  def short_id
    id.first(8)
  end

  def translated_matter_type
    {
      value: matter_type,
      en: MatterType.description_by_id(matter_type)
    }
  end

  def translated_hearing_outcome
    {
      value: hearing_outcome,
      en: OutcomeCode.description_by_id(hearing_outcome)
    }
  end

  def translated_reasons_for_claim
    reasons_for_claim.map do |reason|
      translations(reason, 'helpers.label.steps_reason_for_claim_form.reasons_for_claim_options')
    end
  end

  def translate_plea
    {
      'plea' => translations(plea, 'helpers.label.steps_case_disposal_form.plea_options'),
      'plea_category' => translations(plea_category, 'helpers.label.steps_case_disposal_form.plea_options')
    }
  end

  def translated_letters_and_calls
    pricing = Pricing.for(self)
    [
      { 'type' => translations('letters', 'helpers.label.steps_letters_calls_form.type_options'),
        'count' => letters, 'pricing' => pricing.letters, 'uplift' => letters_uplift },
      { 'type' => translations('calls', 'helpers.label.steps_letters_calls_form.type_options'),
        'count' => calls, 'pricing' => pricing.calls, 'uplift' => calls_uplift },
    ]
  end

  def translated_equality_answers
    {
      'answer_equality' => translations(answer_equality,
                                        'helpers.label.steps_answer_equality_form.answer_equality_options'),
      'disability' => translations(disability, 'helpers.label.steps_equality_questions_form.disability_options'),
      'ethnic_group' => translations(ethnic_group, 'helpers.label.steps_equality_questions_form.ethnic_group_options'),
      'gender' => translations(gender, 'helpers.label.steps_equality_questions_form.gender_options')
    }
  end

  def as_json(*)
    super
      .merge(
        'letters_and_calls' => translated_letters_and_calls,
        'claim_type' => translations(claim_type, 'helpers.label.steps_claim_type_form.claim_type_options'),
        'matter_type' => translated_matter_type,
        'reasons_for_claim' => translated_reasons_for_claim,
        'hearing_outcome' => translated_hearing_outcome,
        **translate_plea,
        **translated_equality_answers
      ).slice!('letters', 'letters_uplift', 'calls', 'calls_uplift', 'app_store_updated_at')
  end
end
