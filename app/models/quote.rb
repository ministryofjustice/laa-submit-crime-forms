class Quote < ApplicationRecord
  belongs_to :prior_authority_application
  has_one :document, lambda {
                       where(document_type: SupportingDocument::QUOTE_DOCUMENT)
                     },
          dependent: :destroy,
          inverse_of: :documentable,
          class_name: 'SupportingDocument',
          as: :documentable

  scope :alternative, -> { where(primary: false) }
  scope :primary, -> { where(primary: true) }

  def total_cost
    if cost_per_item
      (cost_per_item * items) + travel_cost + additional_cost_value
    elsif cost_per_hour
      (cost_per_hour * period / 60) + travel_cost + additional_cost_value
    else
      travel_cost + additional_cost_value
    end
  end

  def travel_cost
    travel_cost_per_hour * travel_time / 60
  end

  def additional_cost_value
    additional_cost_total || 0
  end
end
