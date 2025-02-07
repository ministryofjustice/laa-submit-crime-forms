module DisbursementDetails
  extend ActiveSupport::Concern

  included do
    include DisbursementCosts
  end

  def translated_disbursement_type
    return '' if other_type.nil? && disbursement_type.nil?

    if disbursement_type == DisbursementTypes::OTHER.to_s
      # rubocop:disable Performance/InefficientHashSearch
      # (False positive - Rubocop sees `.values` and wrongly infers OtherDisbursementTypes is a hash)
      known_other = OtherDisbursementTypes.values.include?(OtherDisbursementTypes.new(other_type))
      # rubocop:enable Performance/InefficientHashSearch
      return I18n.t("laa_crime_forms_common.nsm.other_disbursement_type.#{other_type}") if known_other

      other_type
    elsif disbursement_type
      I18n.t("laa_crime_forms_common.nsm.disbursement_type.#{disbursement_type}")
    end
  end

  def complete?
    Nsm::Steps::DisbursementTypeForm.build(self, application: claim).valid? &&
      Nsm::Steps::DisbursementCostForm.build(self, application: claim).tap { _1.add_another = 'no' }.valid?
  end
end
