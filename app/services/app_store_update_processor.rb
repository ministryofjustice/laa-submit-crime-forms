class AppStoreUpdateProcessor
  class << self
    def call(record)
      case record['application_type']
      when 'crm7'
        update_claim(record)
      when 'crm4'
        update_prior_authority_application(record)
      end
    end

    def convert_params(record)
      {
        status: record['application_state'],
        app_store_updated_at: record['updated_at']
      }
    end

    def update_claim(record)
      claim = Claim.find_by(id: record['application_id'])

      return unless claim

      claim.update!(convert_params(record))
      Nsm::AssessmentSyncer.call(claim, record:)
    end

    def update_prior_authority_application(record)
      application = PriorAuthorityApplication.find_by(id: record['application_id'])
      return unless application

      application.update!(convert_params(record))
      PriorAuthority::AssessmentSyncer.call(application, record:)
    end
  end
end
