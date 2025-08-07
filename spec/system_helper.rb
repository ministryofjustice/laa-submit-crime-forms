# frozen_string_literal: true

require 'rails_helper'

# system/support/ files contain system tests configurations and helpers
Dir[File.join(__dir__, 'system/support/**/*.rb')].each { |file| require file }

def attach_ref_to_payload(app)
  # TODO: this method is only needed because we are
  # equating an app store payload with a local record
  # it should be considered tech debt that we aim to get rid of
  # when unifying submissions into one db
  payload = SubmitToAppStore::PriorAuthorityPayloadBuilder.new(application: app).payload
  ref = laa_references.select { _1[:id] == payload[:application_id] }.first[:laa_reference]
  payload[:application][:laa_reference] = ref
  payload
end