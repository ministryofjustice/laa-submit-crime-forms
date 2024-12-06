module ClaimCreatable
  extend ActiveSupport::Concern

  def initialize_application(&block)
    attributes = {
      office_code: (current_provider.office_codes.first unless current_provider.multiple_offices?),
      submitter: current_provider,
      laa_reference: generate_laa_reference
    }
    Claim.create!(attributes).tap(&block)
  end

  def generate_laa_reference
    loop do
      random_reference = "LAA-#{SecureRandom.alphanumeric(6)}"
      break random_reference unless Claim.exists?(laa_reference: random_reference)
    end
  end
end
