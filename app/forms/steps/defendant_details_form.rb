require 'steps/base_form_object'

module Steps
  class DefendantDetailsForm < Steps::BaseFormObject
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

    def show_destroy?
      !main
    end

    def label_key
      ".#{'main_' if main}defendant_field_set"
    end

    def index
      application.defendants.index(record)
    end

    private

    def persist!
      record.update!(attributes)
    end
  end
end
