module PriorAuthorityDetails
  extend ActiveSupport::Concern

  def youth_court_applicable?
    court_type == PriorAuthority::CourtTypeOptions::MAGISTRATE.to_s
  end

  def psychiatric_liaison_applicable?
    court_type == PriorAuthority::CourtTypeOptions::CENTRAL_CRIMINAL.to_s
  end

  def total_cost
    primary_quote&.total_cost
  end

  def total_cost_gbp
    total_cost ? LaaCrimeFormsCommon::NumberTo.pounds(total_cost) : nil
  end

  def further_information_needed?
    pending_further_information.present?
  end

  def correction_needed?
    pending_incorrect_information.present?
  end
end
