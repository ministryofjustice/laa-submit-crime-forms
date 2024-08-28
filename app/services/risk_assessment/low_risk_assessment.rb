# frozen_string_literal: true

module RiskAssessment
  class LowRiskAssessment
    EVIDENCE_MULTIPLIER = 4
    PAGE_MULTIPLIER = 2
    WITNESS_MULTIPLIER = 30
    ADVOCACY_MULTIPLIER = 2

    def initialize(claim)
      @claim = claim
    end

    def assess
      attendance_low_enough? && prep_low_enough?
    end

    def attendance_low_enough?
      total_attendance_time < multiplied_total_advocacy_time
    end

    def prep_low_enough?
      total_prep_time < multiplied_total_advocacy_time ||
        alternative_prep_time < multiplied_total_advocacy_time
    end

    def alternative_prep_time
      prosecution_evidence = (@claim.prosecution_evidence || 0) * EVIDENCE_MULTIPLIER
      number_of_pages = (@claim.defence_statement || 0) * PAGE_MULTIPLIER
      number_of_witnesses = (@claim.number_of_witnesses || 0) * WITNESS_MULTIPLIER
      length_of_video = @claim.time_spent || 0
      prosecution_evidence + number_of_pages + length_of_video - number_of_witnesses
    end

    def total_prep_time
      @claim.work_items.where(work_type: WorkTypes::PREPARATION.to_s).sum(:time_spent)
    end

    def total_attendance_time
      @claim.work_items
            .where(work_type: [WorkTypes::ATTENDANCE_WITH_COUNSEL.to_s, WorkTypes::ATTENDANCE_WITHOUT_COUNSEL.to_s])
            .sum(:time_spent)
    end

    def multiplied_total_advocacy_time
      @multiplied_total_advocacy_time ||=
        ADVOCACY_MULTIPLIER * @claim.work_items.where(work_type: WorkTypes::ADVOCACY.to_s).sum(:time_spent)
    end
  end
end
