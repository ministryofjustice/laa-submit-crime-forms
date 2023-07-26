# frozen_string_literal: true

require 'steps/base_form_object'

module Steps
  class SupportingEvidenceForm < Steps::BaseFormObject
    attribute :send_by_post, :boolean

    private

    def persist!
      application.update!(attributes)
    end
  end
end
