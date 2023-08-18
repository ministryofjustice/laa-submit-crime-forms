class NotifyAppStore
  DEFAULT_IGNORE = %w[claim_id created_at updated_at].freeze
  attr_reader :claim, :notifier, :scorer

  def initialize(claim:, notifier:, scorer:)
    @claim = claim
    @notifier = notifier
    @scorer = scorer
  end

  def notify
    data = claim.as_json.slice!('navigation_stack', 'firm_office_id', 'solicitor_id', 'submitter_id')
    data['disbursements'] = disbursement_data
    data['work_items'] = work_item_data
    data['defendants'] = defendant_data
    data['firm_office'] = claim.firm_office.attributes.slice!('id', *DEFAULT_IGNORE)
    data['solicitor'] = claim.solicitor.attributes.slice!('id', *DEFAULT_IGNORE)
    data['submiter'] = claim.submitter.attributes.slice('email', 'description')

    message = {
      application_id: claim.id,
      json_schema_version: 1,
      application_state: 'submitted',
      application: data
    }
    message[:application_risk] = application_risk if claim.status == 'submitted'

    notifier.send(message:)
  end

  def application_risk
    scorer.calculate(claim)
  end

  def disbursement_data
    claim.disbursements.map do |disbursement|
      data = disbursement.attributes.slice!(*DEFAULT_IGNORE)
      data['disbursement_date'] = data['disbursement_date'].to_s
      data['pricing'] = pricing[disbursement.disbursement_type] || 1.0
      data['vat_rate'] = pricing[:vat]
      data
    end
  end

  def work_item_data
    claim.work_items.map do |work_item|
      data = work_item.attributes.slice!(*DEFAULT_IGNORE)
      data['completed_on'] = data['completed_on'].to_s
      data['pricing'] = pricing[work_item.work_type]
      data
    end
  end

  def defendant_data
    claim.defendants.map do |defendant|
      defendant.attributes.slice!(*DEFAULT_IGNORE)
    end
  end

  def pricing
    @pricing ||= Pricing.for(claim)
  end
end
