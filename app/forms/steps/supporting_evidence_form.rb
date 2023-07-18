# frozen_string_literal: true
require 'steps/base_form_object'

module Steps
  class SupportingEvidenceForm < Steps::BaseFormObject
    attribute :send_by_post, :boolean
  end
end
