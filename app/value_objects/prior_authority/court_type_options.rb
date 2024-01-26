module PriorAuthority
  class CourtTypeOptions < ValueObject
    VALUES = [
      MAGISTRATE = new(:magistrates_court),
      CENTRAL_CRIMINAL = new(:central_criminal_court),
      CROWN = new(:crown_court),
    ].freeze
  end
end
