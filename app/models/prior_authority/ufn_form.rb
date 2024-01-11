module PriorAuthority
  class UfnForm < PriorAuthorityApplication
    validates :ufn, presence: true

    def extended_update(attributes)
      return false unless update(attributes)
      return true unless pre_draft?

      PriorAuthorityApplication.transaction do
        update(status: PriorAuthorityApplication.statuses[:draft],
               ufn_form_status: :complete,
               laa_reference: generate_laa_reference)
      end
      true
    end

    private

    def generate_laa_reference
      proposed_reference = nil
      loop do
        proposed_reference = "LAA-#{SecureRandom.base58(6)}"
        break unless PriorAuthorityApplication.find_by(laa_reference: proposed_reference)
      end
      proposed_reference
    end
  end
end
