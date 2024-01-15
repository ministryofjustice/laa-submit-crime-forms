# frozen_string_literal: true

class ClaimSubmissionMailer < GovukNotifyRails::Mailer
  def notify(claim)
    @claim = claim
    set_template('0403454c-47a5-4540-804c-cb614e77dc22')
    set_personalisation(
      LAA_case_reference: case_reference,
      UFN: unique_file_number,
      main_defendant_name: defendant_name,
      defendant_id: defendant_id_string,
      claim_total: claim_total,
      date: submission_date,
      feedback_url: feedback_url
    )
    mail(to: email_recipient)
  end

  private

  def email_recipient
    Provider.find(@claim.submitter_id).email
  end

  def case_reference
    @claim.laa_reference
  end

  def unique_file_number
    @claim.ufn
  end

  def main_defendant
    @claim.defendants.find { |defendant| defendant.main == true }
  end

  def defendant_name
    main_defendant.full_name
  end

  def maat_id
    main_defendant.maat
  end

  def cntp_order
    @claim.cntp_order
  end

  # Markdown conditionals do not allow to format the string nicely so formatting here.
  def defendant_id_string
    if maat_id.nil?
      "Client's CNTP number: #{cntp_order}"
    else
      "MAAT ID: #{maat_id}"
    end
  end

  def claim_total
    items = {
      work_items: CostSummary::WorkItems.new(@claim.work_items, @claim),
      letters_calls: CostSummary::LettersCalls.new(@claim),
      disbursements: CostSummary::Disbursements.new(@claim.disbursements.by_age, @claim)
    }

    NumberTo.pounds(items.values.filter_map(&:total_cost).sum)
  end

  def submission_date
    DateTime.now.strftime('%d %B %Y')
  end

  def feedback_url
    Rails.configuration.x.contact.feedback_url
  end
end
