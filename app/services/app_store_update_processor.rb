class AppStoreUpdateProcessor
  class << self
    def call(record)
      case record['application_type']
      when 'crm7'
        update_claim(record['application_id'], convert_params(record),
                     record)
      when 'crm4'
        update_prior_authority_application(record['application_id'],
                                           convert_params(record),
                                           record)
      end
    end

    def convert_params(record)
      {
        status: record['application_state'],
        app_store_updated_at: record['updated_at']
      }
    end

    def update_claim(claim_id, params, record)
      claim = Claim.find_by(id: claim_id)

      return unless claim

      claim&.update!(params)
      Nsm::AssessmentSyncer.call(claim, record:)
    end

    def update_prior_authority_application(application_id, params, record)
      application = PriorAuthorityApplication.find_by(id: application_id)
      return unless application

      application.update!(params)
      PriorAuthority::AssessmentSyncer.call(application, record:)
    end
  end
end
