module StageReachedCalculatable
  extend ActiveSupport::Concern

  def stage_reached
    return :prog unless claim_type == ClaimType::NON_STANDARD_MAGISTRATE.to_s

    return :prom unless office_in_undesignated_area

    return :prog if court_in_undesignated_area

    transferred_from_undesignated_area ? :prog : :prom
  end

  def prog_stage_reached?
    stage_reached == :prog
  end
end
