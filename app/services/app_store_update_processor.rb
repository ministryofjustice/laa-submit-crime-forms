class AppStoreUpdateProcessor
  class << self
    def call(record, is_full: false)
      case record['application_type']
      when 'crm7'
        update_claim(record['application_id'], convert_params(record))
      when 'crm4'
        update_prior_authority_application(record['application_id'],
                                           convert_params(record),
                                           (record if is_full))
      end
    end

    def convert_params(record)
      {
        status: record['application_state'],
        app_store_updated_at: record['updated_at']
      }
    end

    def update_claim(claim_id, params)
      claim = Claim.find_by(id: claim_id)

      claim&.update!(params)
    end

    def update_prior_authority_application(application_id, params, full_record_or_nil)
      application = PriorAuthorityApplication.find_by(id: application_id)
      return unless application

      application.update!(params)
      PriorAuthority::AssessmentSyncer.call(application, record: full_record_or_nil)
    end
  end
end
