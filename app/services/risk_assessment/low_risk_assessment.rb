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
      prep_attendance_advocacy? || new_prep_advocacy?
    end

    def prep_attendance_advocacy?
      total_prep_time + total_attendance_time <= multiplied_total_advocacy_time
    end

    def new_prep_advocacy?
      prosecution_evidence = (@claim.prosecution_evidence || 0) * EVIDENCE_MULTIPLIER
      number_of_pages = (@claim.defence_statement || 0) * PAGE_MULTIPLIER
      number_of_witnesses = (@claim.number_of_witnesses || 0) * WITNESS_MULTIPLIER
      length_of_video = @claim.time_spent || 0
      new_prep_time = prosecution_evidence + number_of_pages + length_of_video - number_of_witnesses
      multiplied_advocacy_time = multiplied_total_advocacy_time
      new_prep_time <= multiplied_advocacy_time && total_attendance_time <= multiplied_advocacy_time
    end

    def total_prep_time
      @claim.work_items.filter { |item| item.work_type == 'preparation' }.sum(&:time_spent)
    end

    def total_attendance_time
      @claim.work_items.filter do |item|
        item.work_type == 'attendance_without_counsel' || item.work_type == 'attendance_with_counsel'
      end.sum(&:time_spent)
    end

    def multiplied_total_advocacy_time
      ADVOCACY_MULTIPLIER * @claim.work_items.filter { |item| item.work_type == 'advocacy' }.sum(&:time_spent)
    end
  end
end
