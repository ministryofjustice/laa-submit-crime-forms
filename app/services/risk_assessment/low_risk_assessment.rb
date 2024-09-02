# frozen_string_literal: true

module RiskAssessment
  class LowRiskAssessment
    EVIDENCE_MULTIPLIER = 2
    WITNESS_MULTIPLIER = 30
    ADVOCACY_MULTIPLIER = 2

    def initialize(claim)
      @claim = claim
    end

    def assess
      attendance_low_enough? && prep_low_enough?
    end

    def attendance_low_enough?
      total_attendance_time <= multiplied_total_advocacy_time
    end

    def prep_low_enough?
      total_prep_time - prep_allowances <= multiplied_total_advocacy_time
    end

    def prep_allowances
      evidence_allowance = (@claim.prosecution_evidence || 0) * EVIDENCE_MULTIPLIER
      statement_allowance = (@claim.defence_statement || 0) * EVIDENCE_MULTIPLIER
      video_allowance = (@claim.time_spent || 0) * EVIDENCE_MULTIPLIER
      witness_allowance = (@claim.number_of_witnesses || 0) * WITNESS_MULTIPLIER
      evidence_allowance + statement_allowance + video_allowance + witness_allowance
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
