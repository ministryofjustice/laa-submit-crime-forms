class OtherDisbursementTypes < ValueObject
  VALUES = [
    ACCIDENT_RECONSTRUCTION_REPOR = new(:accident_reconstruction_report),
    ACCIDENT_EMERGENCY_REPORT = new(:accident_emergency_report),
    ACCOUNTANTS = new(:accountants),
    ARCHITECTS_SURVEYOR = new(:architects_surveyor),
    BACK_CALCULATIONS = new(:back_calculations),
    CAR_TRAVEL = new(:car_travel),
    CAELL_PHONE_SITE_ANALAYSIS = new(:caell_phone_site_analaysis),
    COMPUTER_EXPERTS = new(:computer_experts),
    CONSULTANT_MEDICAL_REPORTS = new(:consultant_medical_reports),
    DNA_TESTING = new(:dna_testing),
    DRUG_EXPERT_REPORT = new(:drug_expert_report),
    ENGINEER_MECHANICAL_ENGINEER = new(:engineer_mechanical_engineer),
    ENQUIRY_AGENTS = new(:enquiry_agents),
    FACIAL_MAPPING_EXPERTS = new(:facial_mapping_experts),
    FINGERPRINT_EXPERTS = new(:fingerprint_experts),
    FIRE_INVESTGATION_REPORT = new(:fire_investgation_report),
    FORENSIC_SCIENTISTS = new(:forensic_scientists),
    GENERAL_PRACTIONERS = new(:general_practioners),
    HANDWRITING_EXPERTS = new(:handwriting_experts),
    INTERPRETERS = new(:interpreters),
    LIP_READERS = new(:lip_readers),
    MEDICAL_REPORT = new(:medical_report),
    METEOROLOGIST = new(:meteorologist),
    OVERNIGHT_EXPENSES = new(:overnight_expenses),
    PAEDIATRICIANS_REPORT = new(:paediatricians_report),
    PATHOLOGISTS = new(:pathologists),
    PHOTOCOPYING = new(:photocopying),
    PLANS_PHOTOGRAPHS = new(:plans_photographs),
    PSYCHIATRIC_REPORTS = new(:psychiatric_reports),
    PHSYCOLOGICAL_REPORTS = new(:phsycological_reports),
    TELECOMMUNICATIONS_EXPERT = new(:telecommunications_expert),
    TRANSCRIPTS = new(:transcripts),
    TRANSLATORS = new(:translators),
    TRAVEL_EXPENSES_EXCL_CAR = new(:travel_expenses_excl_car),
    VETERNARIAN_REPORT = new(:veternarian_report),
    VOICE_RECOGNITION_EXPERTS = new(:voice_recognition_experts),
  ].freeze

  def translated
    I18n.t("helpers.other_disbursement_type.#{value}")
  end

  delegate :blank?, to: :value
end
