# frozen_string_literal: true

module Nsm
  class SubmissionMailer < GovukNotifyRails::Mailer
    def notify(claim)
      @claim = claim
      set_template('0403454c-47a5-4540-804c-cb614e77dc22')
      set_personalisation(
        LAA_case_reference: case_reference,
        UFN: unique_file_number,
        main_defendant_name: defendant_name,
        defendant_reference: defendant_reference_string,
        claim_total: claim_total,
        date: submission_date,
      )
      mail(to: email_recipient)
    end

    private

    def email_recipient
      @claim.submitter.email
    end

    def case_reference
      @claim.laa_reference
    end

    def unique_file_number
      @claim.ufn
    end

    def defendant_name
      @claim.main_defendant.full_name
    end

    def maat_id
      @claim.main_defendant.maat
    end

    def cntp_order
      @claim.cntp_order
    end

    # Markdown conditionals do not allow to format the string nicely so formatting here.
    def defendant_reference_string
      if maat_id.nil?
        "Client's CNTP number: #{cntp_order}"
      else
        "MAAT ID: #{maat_id}"
      end
    end

    def claim_total
      items = {
        work_items: Nsm::CostSummary::WorkItems.new(@claim.work_items, @claim),
        letters_calls: Nsm::CostSummary::LettersCalls.new(@claim),
        disbursements: Nsm::CostSummary::Disbursements.new(@claim.disbursements.by_age, @claim)
      }

      NumberTo.pounds(items.values.filter_map(&:total_cost).sum)
    end

    def submission_date
      DateTime.now.to_fs(:stamp)
    end
  end
end
