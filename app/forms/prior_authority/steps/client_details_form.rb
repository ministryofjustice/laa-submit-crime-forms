module PriorAuthoritySteps
  class ClaimDetailsForm < Steps::BaseFormObject

    attribute :client_first_name, :string
    attribute :client_last_name, :string
    attribute :client_date_of_birth, :date


    validates :client_first_name, presence: true
    validates :client_last_name, presence: true
    validates :client_date_of_birth, presence: true

    private

    def persist!
      application.update!(attributes_to_reset)
    end

    def attributes_to_reset
      attributes.merge(
        client_first_name:,
        client_last_name:,
        client_date_of_birth:
      )
    end
  end
end
