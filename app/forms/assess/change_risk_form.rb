module Assess
  class ChangeRiskForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment
    RiskLevels = Struct.new(:id, :level)
    AVAILABLE_RISKS = [
      RiskLevels.new('low', 'Low risk'),
      RiskLevels.new('medium', 'Medium risk'),
      RiskLevels.new('high', 'High risk'),
    ].freeze

    attribute :id
    attribute :risk_level
    attribute :explanation
    attribute :current_user

    validates :claim, presence: true
    validates :risk_level, presence: true, inclusion: { in: AVAILABLE_RISKS.map(&:id) }
    validate :risk_level_changed
    validates :explanation, presence: true, if: :risk_changed?

    def save
      return false unless valid?

      previous_risk_level = claim.risk
      SubmittedClaim.transaction do
        claim.update!(risk: risk_level)
        Event::ChangeRisk.build(claim:, explanation:, previous_risk_level:, current_user:)
      end

      true
    rescue StandardError
      false
    end

    def claim
      SubmittedClaim.find_by(id:)
    end

    def available_risks
      self.class::AVAILABLE_RISKS.reject { |risk| risk.id == claim.risk }
    end

    private

    def risk_level_changed
      return if risk_changed?

      errors.add(:risk_level, :unchanged)
    end

    def risk_changed?
      claim&.risk != risk_level
    end
  end
end
