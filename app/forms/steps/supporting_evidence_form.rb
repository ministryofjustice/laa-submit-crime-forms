# frozen_string_literal: true

module Steps
  class SupportingEvidenceForm < Steps::BaseFormObject
    attribute :send_by_post, :boolean

    private

    def persist!
      application.update!(attributes)
    end
  end
end
