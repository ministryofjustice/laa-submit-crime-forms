module ClaimCreatable
  extend ActiveSupport::Concern

  def initialize_application(&block)
    attributes = {
      office_code: (current_provider.office_codes.first unless current_provider.multiple_offices?),
      submitter: current_provider,
    }
    Claim.create!(attributes).tap(&block)
  end
end
