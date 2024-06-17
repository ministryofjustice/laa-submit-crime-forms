module Nsm
  class Resetter
    def call
      raise 'NEVER do this with real-life data' if HostEnv.production?

      Claim.where.not(status: :draft).find_each do |claim|
        reset_claim_fields(claim)
        reset_work_item_fields(claim)
        reset_disbursement_fields(claim)
        resubmit(claim)
      end
    end

    def reset_claim_fields(claim)
      claim.update!(
        status: 'submitted',
        assessment_comment: nil,
        allowed_letters: nil,
        allowed_letters_uplift: nil,
        letters_adjustment_comment: nil,
        allowed_calls: nil,
        allowed_calls_uplift: nil,
        calls_adjustment_comment: nil
      )
    end

    def reset_work_item_fields(claim)
      claim.work_items.each do |work_item|
        work_item.update!(
          allowed_time_spent: nil,
          allowed_uplift: nil,
          adjustment_comment: nil
        )
      end
    end

    def reset_disbursement_fields(claim)
      claim.disbursements.each do |disbursement|
        disbursement.update!(
          allowed_total_cost_without_vat: nil,
          allowed_miles: nil,
          allowed_apply_vat: nil,
          allowed_vat_amount: nil,
          adjustment_comment: nil
        )
      end
    end

    def resubmit(claim)
      SubmitToAppStore.new.perform(submission: claim)
    end
  end
end
