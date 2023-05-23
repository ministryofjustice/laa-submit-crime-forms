require 'steps/base_form_object'

module Steps
  class DefendantDetailsForm < Steps::BaseFormObject
    attribute :_destroy, :boolean, default: false
    attribute :id, :string
    attribute :full_name, :string
    attribute :maat, :string
    attribute :position, :integer
    attribute :main, :boolean, default: false

    validates :full_name, presence: true
    validates :maat, presence: true, if: :maat_required?

    def persisted?
      id.present?
    end

    def maat_required?
      application.claim_type != ClaimType::BREACH_OF_INJUNCTION.to_s
    end
  end
end
