class SubmitToAppStore
  class NsmPayloadBuilder
    DEFAULT_IGNORE = %w[claim_id created_at updated_at].freeze
    WORK_ITEM_IGNORE = %[allowed_uplift allowed_time_spent].freeze

    attr_reader :claim, :scorer

    def initialize(claim:, scorer: RiskAssessment::RiskAssessmentScorer)
      @claim = claim
      @scorer = scorer
    end

    def payload
      {
        application_id: claim.id,
        json_schema_version: 1,
        application_state: 'submitted',
        application: data,
        application_risk: scorer.calculate(claim),
        application_type: 'crm7'
      }
    end

    private

    def data
      data = claim.as_json(except: %w[navigation_stack firm_office_id solicitor_id submitter_id])
      data.merge(
        'disbursements' => disbursement_data,
        'work_items' => work_item_data,
        'defendants' => defendant_data,
        'firm_office' => firm_office_data,
        'solicitor' => claim.solicitor.attributes.except('id', *DEFAULT_IGNORE),
        'submitter' => claim.submitter.attributes.slice('email', 'description'),
        'supporting_evidences' => supporting_evidence,
        'cost_totals' => costs_data,
        'vat_rate' => pricing[:vat],
      )
    end

    def costs_data
      claim.cost_totals.map do |cost|
        cost.as_json(except: DEFAULT_IGNORE)
      end
    end

    def firm_office_data
      claim.firm_office.attributes.except('id', 'account_number', *DEFAULT_IGNORE).merge(
        'account_number' => claim.office_code
      )
    end

    def disbursement_data
      claim.disbursements.map do |disbursement|
        data = disbursement.as_json(except: DEFAULT_IGNORE)
        data['disbursement_date'] = data['disbursement_date'].to_s
        data['pricing'] = pricing[disbursement.disbursement_type] || 1.0
        data['vat_rate'] = pricing[:vat]
        data['vat_amount'] = data['vat_amount'].to_f
        data['total_cost_without_vat'] = data['total_cost_without_vat'].to_f
        data
      end
    end

    def work_item_data
      claim.work_items.map do |work_item|
        data = work_item.as_json(except: DEFAULT_IGNORE.concat(WORK_ITEM_IGNORE))
        data['completed_on'] = data['completed_on'].to_s
        data['pricing'] = pricing[work_item.work_type]
        data
      end
    end

    def defendant_data
      claim.defendants.map do |defendant|
        defendant.as_json(only: %i[id maat main position first_name last_name])
      end
    end

    def pricing
      @pricing ||= Pricing.for(claim)
    end

    def supporting_evidence
      claim.supporting_evidence.map do |evidence|
        evidence.as_json.slice!('claim_id')
      end
    end
  end
end
