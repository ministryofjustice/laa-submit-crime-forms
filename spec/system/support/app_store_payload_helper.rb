module AppStorePayloadHelper
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
  def stub_pa_app_store_payload(application, state = nil, laa_reference = 'LAA-ABC123')
    application.reload

    payload = SubmitToAppStore::PriorAuthorityPayloadBuilder.new(application:).payload.with_indifferent_access
    payload[:application_state] = state || application.state
    payload[:application][:laa_reference] = laa_reference
    stub_request(:get, "https://app-store.example.com/v1/application/#{application.id}").to_return(
      status: 200,
      body: payload.to_json
    )
  end

  def stub_nsm_app_store_payload(claim, state = nil, laa_reference = 'LAA-ABC123')
    claim.reload

    payload = SubmitToAppStore::NsmPayloadBuilder.new(claim:).payload.with_indifferent_access
    payload[:application_state] = state || claim.state
    payload[:application][:laa_reference] = laa_reference
    claim.work_items.each do |work_item|
      element = payload.dig(:application, :work_items).find { _1[:id] == work_item.id }
      if work_item.allowed_time_spent
        element['time_spent_original'] = work_item.time_spent
        element['time_spent'] = work_item.allowed_time_spent
      end
      element['adjustment_comment'] = work_item.adjustment_comment
    end

    claim.disbursements.each do |disbursement|
      element = payload.dig(:application, :disbursements).find { _1['id'] == disbursement.id }
      if disbursement.allowed_miles
        element['miles_original'] = disbursement.miles
        element['miles'] = disbursement.allowed_miles
      end
      if disbursement.allowed_total_cost_without_vat
        element['total_cost_without_vat_original'] = disbursement.total_cost_without_vat
        element['total_cost_without_vat'] = disbursement.allowed_total_cost_without_vat
      end
      if disbursement.allowed_apply_vat
        element['apply_vat_original'] = disbursement.apply_vat
        element['apply_vat'] = disbursement.allowed_apply_vat
      end
      if disbursement.allowed_vat_amount
        element['vat_amount_original'] = disbursement.vat_amount
        element['vat_amount'] = disbursement.allowed_vat_amount
      end
      element['adjustment_comment'] = disbursement.adjustment_comment
    end

    if claim.allowed_letters
      element = payload.dig(:application, :letters_and_calls).find { _1['type'] == 'letters' }
      element['count_original'] = claim.letters
      element['count'] = claim.allowed_letters
      element['adjustment_comment'] = claim.letters_adjustment_comment
    end

    if claim.allowed_calls
      element = payload.dig(:application, :letters_and_calls).find { _1['type'] == 'calls' }
      element['count_original'] = claim.calls
      element['count'] = claim.allowed_calls
      element['adjustment_comment'] = claim.calls_adjustment_comment
    end

    unless claim.allowed_youth_court_fee.nil?
      payload[:application]['youth_court_fee_adjustment_comment'] = claim.youth_court_fee_adjustment_comment
      payload[:application]['include_youth_court_fee_original'] = claim.include_youth_court_fee
      payload[:application]['include_youth_court_fee'] = claim.allowed_youth_court_fee
    end

    payload[:application]['further_information'] = claim.further_informations.map(&:as_json)
    payload[:application]['resubmission_deadline'] = claim.further_informations.pluck(:resubmission_deadline).uniq.max

    stub_request(:get, "https://app-store.example.com/v1/application/#{claim.id}").to_return(
      status: 200,
      body: payload.to_json
    )
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

  def attach_ref_to_payload(app)
    # TODO: this method is only needed because we are
    # equating an app store payload with a local record
    # it should be considered tech debt that we aim to get rid of
    # when unifying submissions into one db
    payload = nil
    case app.class.name
    when 'PriorAuthorityApplication'
      payload = SubmitToAppStore::PriorAuthorityPayloadBuilder.new(application: app).payload
    when 'Claim'
      payload = SubmitToAppStore::NsmPayloadBuilder.new(claim: app).payload
    end

    ref = laa_references.select { _1[:id] == payload[:application_id] }.first[:laa_reference]
    payload[:application][:laa_reference] = ref
    payload
  end
end

RSpec.configure do |config|
  config.include AppStorePayloadHelper, type: :system
end
