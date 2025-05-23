class Provider < ApplicationRecord
  devise :lockable, :timeoutable, :trackable,
         :omniauthable, omniauth_providers: %i[saml]

  store_accessor :settings,
                 :legal_rep_first_name,
                 :legal_rep_last_name,
                 :legal_rep_telephone

  def display_name
    email
  end

  def multiple_offices?
    office_codes.size > 1
  end

  has_many :prior_authority_applications, dependent: :destroy

  class << self
    def from_omniauth(auth, office_codes)
      find_or_initialize_by(auth_provider: auth.provider, uid: auth.uid).tap do |record|
        record.update(
          email: auth.info.email,
          description: auth.info.description,
          roles: auth.info.roles,
          office_codes: office_codes,
        )
      end
    end
  end
end
