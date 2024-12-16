module Nsm
  module AppStorePayloadHelper
    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    def stub_app_store_payload(claim, state = nil)
      claim.reload

      payload = SubmitToAppStore::NsmPayloadBuilder.new(claim:).payload.with_indifferent_access
      payload[:application_state] = state || claim.state

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
  end
end

RSpec.configure do |config|
  config.include Nsm::AppStorePayloadHelper, type: :system
end
