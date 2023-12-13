require 'steps/base_form_object'

module Steps
  class SolicitorDeclarationForm < Steps::BaseFormObject
    attribute :signatory_name, :string
    validates :signatory_name, presence: true, format: { with: /\A[a-z,.'\-]+( +[a-z,.'\-]+)+\z/i }

    private

    def persist!
      application.status = :submitted
      application.update!(attributes)

      ClaimCalculator.new(claim: application).save_totals
      NotifyAppStore.new.process(claim: application)
    end
  end
end
