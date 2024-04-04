class Quote < ApplicationRecord
  belongs_to :prior_authority_application
  has_one :document, lambda {
                       where(document_type: SupportingDocument::SUPPORTED_FILE_TYPES)
                     },
          dependent: :destroy,
          inverse_of: :documentable,
          class_name: 'SupportingDocument',
          as: :documentable

  scope :alternative, -> { where(primary: false) }
  scope :primary, -> { where(primary: true) }

  def total_cost
    base_cost = ::PriorAuthority::Steps::ServiceCostForm.build(self,
                                                               application: prior_authority_application).total_cost
    base_cost + travel_cost + additional_cost_value
  end

  def travel_cost
    ::PriorAuthority::Steps::TravelDetailForm.build(self, application: prior_authority_application).total_cost
  end

  def additional_cost_value
    if primary
      AdditionalCost.where(prior_authority_application_id:).sum(&:total_cost)
    else
      additional_cost_total
    end
  end

  def contact_full_name
    "#{contact_first_name} #{contact_last_name}"
  end
end
