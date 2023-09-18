# frozen_string_literal: true

module RiskAssessment
  class LowRiskAssessment
    def initialize(claim)
      @claim = claim
    end

    def assess
      prep_attendance_advocacy? || new_prep_advocacy?
    end

    def prep_attendance_advocacy?
      total_prep_time + total_attendance_time <= total_advocacy_time
    end

    def new_prep_advocacy?
      prosecution_evidence = (@claim.prosecution_evidence || 0) * 4
      number_of_pages = (@claim.defence_statement || 0) * 2
      number_of_witnesses = (@claim.number_of_witnesses || 0) * 30
      length_of_video = @claim.time_spent || 0

      prosecution_evidence + number_of_pages + length_of_video - number_of_witnesses <= total_advocacy_time
    end

    def total_prep_time
      @claim.work_items.filter { |item| item.work_type == 'preparation' }.sum(&:time_spent)
    end

    def total_attendance_time
      @claim.work_items.filter { |item| item.work_type == 'attendance_without_counsel' }.sum(&:time_spent)
    end

    def total_advocacy_time
      2 * @claim.work_items.filter { |item| item.work_type == 'advocacy' }.sum(&:time_spent)
    end
  end
end
