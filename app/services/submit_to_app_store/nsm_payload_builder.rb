class SubmitToAppStore
  class NsmPayloadBuilder
    DEFAULT_IGNORE = %w[claim_id created_at updated_at].freeze

    attr_reader :claim, :scorer

    def initialize(claim:, scorer: RiskAssessment::RiskAssessmentScorer)
      @claim = claim
      @scorer = scorer
    end

    def payload
      {
        application_id: claim.id,
        json_schema_version: 1,
        application_state: claim.state,
        application: data,
        application_risk: scorer.calculate(claim),
        application_type: 'crm7'
      }
    end

    private

    def data
      direct_attributes.merge(
        'status' => claim.state,
        'vat_rate' => pricing[:vat].to_f,
        'stage_reached' => claim.stage_reached,
        'disbursements' => disbursements,
        'work_items' => work_items,
        'defendants' => defendants,
        'firm_office' => firm_office,
        'solicitor' => solicitor,
        'submitter' => submitter,
        'supporting_evidences' => supporting_evidences,
        'further_information' => further_information,
        'work_item_pricing' => work_item_pricing,
        'cost_summary' => cost_summary
      )
    end

    def direct_attributes
      claim.as_json(except: %w[navigation_stack firm_office_id solicitor_id submitter_id allowed_calls
                               allowed_calls_uplift allowed_letters allowed_letters_uplift
                               calls_adjustment_comment letters_adjustment_comment state])
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

    # rubocop:disable Metrics/AbcSize
    def disbursements
      claim.disbursements.map do |disbursement|
        data = disbursement.as_json(except: [*DEFAULT_IGNORE, 'allowed_total_cost_without_vat', 'allowed_vat_amount',
                                             'adjustment_comment', 'allowed_apply_vat', 'allowed_miles'])
        data['disbursement_date'] = data['disbursement_date'].to_s
        data['pricing'] = pricing[disbursement.disbursement_type].to_f || 1.0
        data['vat_rate'] = pricing[:vat].to_f
        data['vat_amount'] = data['vat_amount'].to_f
        data['total_cost_without_vat'] = data['total_cost_without_vat'].to_f
        data
      end
    end
    # rubocop:enable Metrics/AbcSize

    def work_items
      claim.work_items.map do |work_item|
        data = work_item.as_json(except: [*DEFAULT_IGNORE, 'allowed_uplift', 'allowed_time_spent', 'adjustment_comment',
                                          'allowed_work_type'])
        data['completed_on'] = data['completed_on'].to_s
        data['pricing'] = pricing[work_item.work_type].to_f
        data
      end
    end

    def defendants
      claim.defendants.map do |defendant|
        defendant.as_json(only: %i[id maat main position first_name last_name])
      end
    end

    def pricing
      @pricing ||= Pricing.for(claim)
    end

    def supporting_evidences
      claim.supporting_evidence.map do |evidence|
        evidence.as_json.slice!('claim_id')
      end
    end

    def work_item_pricing
      work_types = WorkTypes.values.select { _1.display_to_caseworker?(claim) }.map(&:to_s)
      pricing.as_json.select { |k, _v| k.in?(work_types) }.transform_values(&:to_f)
    end

    def further_information
      claim.further_informations.map do |further_information|
        further_information.as_json(only: FURTHER_INFO_ATTRIBUTES).merge(
          'documents' => further_info_documents(further_information),
          'new' => further_information == claim.pending_further_information
        )
      end
    end

    def further_info_documents(further_information)
      further_information.supporting_documents.map do |document|
        document.as_json(only: %i[file_name
                                  file_type
                                  file_size
                                  file_path
                                  document_type])
      end
    end

    FURTHER_INFO_ATTRIBUTES = %i[information_requested
                                 information_supplied
                                 caseworker_id
                                 requested_at].freeze

    def cost_summary
      Nsm::CheckAnswers::CostSummaryCard.new(claim).table_fields(formatted: false).index_by do |row|
        row.delete(:name)
      end
    end
  end
end
