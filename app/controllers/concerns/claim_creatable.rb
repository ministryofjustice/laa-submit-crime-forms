module ClaimCreatable
  extend ActiveSupport::Concern
  include GeneratesLaaReference

  def initialize_application(&block)
    attributes = {
      office_code: (current_provider.office_codes.first unless current_provider.multiple_offices?),
      submitter: current_provider,
      laa_reference: generate_laa_reference
    }
    Claim.create!(attributes).tap(&block)
  end
end
