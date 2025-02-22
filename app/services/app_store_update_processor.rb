class AppStoreUpdateProcessor
  class << self
    def call(record, local_record = nil)
      case record['application_type']
      when 'crm7'
        update_claim(record, local_record)
      when 'crm4'
        update_prior_authority_application(record, local_record)
      end
    end

    def convert_params(record)
      {
        state: record['application_state'],
        app_store_updated_at: record['last_updated_at']
      }
    end

    def update_claim(record, local_record)
      claim = local_record || Claim.find_by(id: record['application_id'])

      return unless claim

      claim.update!(convert_params(record))
      Nsm::AssessmentSyncer.call(claim, record:)
    end

    def update_prior_authority_application(record, local_record)
      application = local_record || PriorAuthorityApplication.find_by(id: record['application_id'])
      return unless application

      application.update!(convert_params(record))
      PriorAuthority::AssessmentSyncer.call(application, record:)
    end
  end
end
