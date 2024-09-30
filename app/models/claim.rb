class Claim < ApplicationRecord
  include LettersAndCallsCosts
  include StageReachedCalculatable

  belongs_to :submitter, class_name: 'Provider'
  belongs_to :firm_office, optional: true
  belongs_to :solicitor, optional: true
  has_many :defendants, -> { order(:position) }, dependent: :destroy, as: :defendable, inverse_of: :defendable
  has_one :main_defendant, lambda {
                             where(main: true)
                           }, class_name: 'Defendant', dependent: nil, as: :defendable, inverse_of: :defendable
  has_many :work_items, -> { order(:completed_on, :work_type, :id) }, dependent: :destroy, inverse_of: :claim
  has_many :disbursements, lambda {
                             order(:disbursement_date, :disbursement_type, :id)
                           }, dependent: :destroy, inverse_of: :claim
  has_many :supporting_evidence, -> { order(:created_at, :file_name) },
           dependent: :destroy,
           inverse_of: :documentable,
           class_name: 'SupportingDocument',
           as: :documentable
  has_many :further_informations, dependent: :destroy, inverse_of: :submission, as: :submission

  scope :reviewed, -> { where(state: %i[granted part_grant rejected sent_back expired further_info]) }
  scope :submitted_or_resubmitted, -> { where(state: %i[submitted provider_updated]) }

  scope :for, ->(provider) { where(office_code: provider.office_codes).or(where(office_code: nil, submitter: provider)) }

  enum :state, { draft: 'draft', submitted: 'submitted', granted: 'granted', part_grant: 'part_grant',
                 sent_back: 'sent_back', rejected: 'rejected', expired: 'expired', provider_updated: 'provider_updated' }

  def date
    rep_order_date || cntp_date
  end

  def short_id
    id.first(8)
  end

  def letters_and_calls_payload
    pricing = Pricing.for(self)
    [
      { 'type' => 'letters', 'count' => letters, 'pricing' => pricing.letters.to_f, 'uplift' => letters_uplift },
      { 'type' => 'calls', 'count' => calls, 'pricing' => pricing.calls.to_f, 'uplift' => calls_uplift },
    ]
  end

  def as_json(*)
    super
      .merge(
        'letters_and_calls' => letters_and_calls_payload,
      ).except('letters', 'letters_uplift', 'calls', 'calls_uplift', 'app_store_updated_at')
  end

  def work_item_position(work_item)
    sorted_work_item_ids.index(work_item.id) + 1
  end

  def update_work_item_positions!
    updated_attributes = sorted_work_item_positions.index_by { |d| d[:id] }

    WorkItem.transaction do
      WorkItem.update(updated_attributes.keys, updated_attributes.values)
    end
  end

  def disbursement_position(disbursement)
    sorted_disbursement_ids.index(disbursement.id) + 1
  end

  def update_disbursement_positions!
    updated_attributes = sorted_disbursement_positions.index_by { |d| d[:id] }

    Disbursement.transaction do
      Disbursement.update(updated_attributes.keys, updated_attributes.values)
    end
  end

  def cost_summary
    @cost_summary ||= Nsm::CheckAnswers::CostSummaryCard.new(self, show_adjustments: true)
  end
  delegate :show_adjusted?, to: :cost_summary

  def pending_further_information
    further_informations.where(created_at: app_store_updated_at..).order(:created_at).last
  end

  private

  def sorted_work_item_ids
    @sorted_work_item_ids ||= work_items.sort_by do |workitem|
      [
        workitem.completed_on || Time.new(2000, 1, 1).in_time_zone.to_date,
        workitem.work_type&.downcase || '',
        workitem.created_at
      ]
    end.map(&:id)
  end

  def sorted_work_item_positions
    @sorted_work_item_positions ||= sorted_work_item_ids.each_with_object([]).with_index do |(id, memo), idx|
      memo << { id: id, position: idx + 1 }
    end
  end

  def sorted_disbursement_ids
    @sorted_disbursement_ids ||= disbursements.sort_by do |disb|
      [
        disb.disbursement_date || Time.new(2000, 1, 1).in_time_zone.to_date,
        disb.translated_disbursement_type&.downcase,
        disb.created_at
      ]
    end.map(&:id)
  end

  def sorted_disbursement_positions
    @sorted_disbursement_positions ||= sorted_disbursement_ids.each_with_object([]).with_index do |(id, memo), idx|
      memo << { id: id, position: idx + 1 }
    end
  end
end
