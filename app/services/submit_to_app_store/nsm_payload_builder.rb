class SubmitToAppStore
  class NsmPayloadBuilder
    DEFAULT_IGNORE = %w[claim_id created_at updated_at].freeze

    attr_reader :claim

    # If we are submitting for the first time, `claim` will be a Claim object
    # If this is an RFI look, `claim` will be an AppStore::V1::Nsm::Claim object
    def initialize(claim:)
      @claim = claim
      @latest_payload = first_submission? ? nil : latest_payload
    end

    def first_submission?
      claim.is_a?(Claim)
    end

    def payload
      {
        application_id: claim.id,
        json_schema_version: 1,
        application_state: first_submission? ? 'submitted' : 'provider_updated',
        application: validated_payload,
        application_type: 'crm7'
      }
    end

    private

    def validated_payload
      construct_payload.tap do |payload|
        issues = LaaCrimeFormsCommon::Validator.validate(:nsm, payload)
        raise "Validation issues detected for #{claim.id}: #{issues.to_sentence}" if issues.any?
      end
    end

    def construct_payload
      first_submission? ? submit_payload : send_back_payload
    end

    def latest_payload
      AppStoreClient.new.get(claim.id)
    end

    def submit_payload
      direct_attributes.merge(
        'status' => claim.state,
        'vat_rate' => claim.rates.vat.to_f,
        'stage_reached' => claim.stage_reached,
        'disbursements' => disbursements,
        'work_items' => work_items,
        'defendants' => defendants,
        'firm_office' => firm_office,
        'solicitor' => solicitor,
        'submitter' => submitter,
        'supporting_evidences' => supporting_evidences,
        'work_item_pricing' => work_item_pricing
      )
    end

    def send_back_payload
      @latest_payload['application'].merge('further_information' => further_information, 'status' => 'provider_updated',
                                           'updated_at' => DateTime.current.as_json)
    end

    def direct_attributes
      claim.as_json(except: %w[viewed_steps navigation_stack firm_office_id solicitor_id submitter_id allowed_calls
                               allowed_calls_uplift allowed_letters allowed_letters_uplift allowed_youth_court_fee
                               youth_court_fee_adjustment_comment calls_adjustment_comment letters_adjustment_comment
                               state core_search_fields submit_to_app_store_completed send_notification_email_completed
                               originally_submitted_at])
    end

    def firm_office
      claim.firm_office.attributes.except('id', 'account_number', *DEFAULT_IGNORE).merge(
        'account_number' => claim.office_code
      )
    end

    def solicitor
      claim.solicitor.attributes.except('id', *DEFAULT_IGNORE)
    end

    def submitter
      claim.submitter.attributes.slice('email', 'description')
    end

    def disbursements
      claim.disbursements.map do |disbursement|
        data = disbursement.as_json(except: [*DEFAULT_IGNORE, 'allowed_total_cost_without_vat', 'allowed_vat_amount',
                                             'adjustment_comment', 'allowed_apply_vat', 'allowed_miles'])
        augment_disbursement_data(data, disbursement)
        data
      end
    end

    def augment_disbursement_data(data, disbursement)
      data['disbursement_date'] = data['disbursement_date'].to_s
      data['pricing'] = claim.rates.disbursements[disbursement.disbursement_type.to_sym].to_f || 1.0
      data['vat_rate'] = claim.rates.vat.to_f
      data['vat_amount'] = disbursement.vat
      # For backwards compatibility, include the calculated total if there is no direct total
      data['total_cost_without_vat'] ||= disbursement.total_cost_pre_vat
    end

    def work_items
      claim.work_items.map do |work_item|
        data = work_item.as_json(except: [*DEFAULT_IGNORE, 'allowed_uplift', 'allowed_time_spent', 'adjustment_comment',
                                          'allowed_work_type'])
        data['completed_on'] = data['completed_on'].to_s
        data['pricing'] = claim.rates.work_items[work_item.work_type.to_sym].to_f
        data
      end
    end

    def defendants
      claim.defendants.map do |defendant|
        defendant.as_json(only: %i[id maat main position first_name last_name])
      end
    end

    def supporting_evidences
      claim.supporting_evidence.map do |evidence|
        evidence.as_json.slice!('claim_id')
      end
    end

    def work_item_pricing
      WorkTypes.values
               .select { _1.display_to_caseworker?(claim) }
               .to_h { [_1.to_s, claim.rates.work_items[_1.to_sym].to_f] }
    end

    def further_information
      claim.further_informations.map(&:as_json)
    end
  end
end
