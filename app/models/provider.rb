class Provider < ApplicationRecord
  has_person_name

  devise :lockable, :timeoutable, :trackable,
         :omniauthable, omniauth_providers: %i[entra_id]

  store_accessor :settings,
                 :legal_rep_first_name,
                 :legal_rep_last_name,
                 :legal_rep_telephone

  def display_name
    return email if first_name.nil? && last_name.nil?

    name.full
  end

  def multiple_offices?
    office_codes.size > 1
  end

  has_many :prior_authority_applications, dependent: :destroy

  class << self
    def from_omniauth(auth, office_codes)
      sorted_office_codes = office_codes.sort

      get_user(auth, sorted_office_codes).tap do |record|
        attributes = {
          first_name: auth.info.first_name,
          last_name: auth.info.last_name,

          email: auth.info.email,
          description: auth.info.description,
          roles: auth.info.roles || [],
          office_codes: sorted_office_codes,
          auth_provider: auth.provider,
          uid: auth.uid
        }

        if record.persisted?
          record.update!(attributes)
        else
          record.assign_attributes(attributes)
          record.save!
        end
      end
    end

    private

    def get_user(auth, office_codes)
      where(email: auth.info.email)
        .find { |u| u.office_codes.sort == office_codes } ||
        find_by(auth_provider: auth.provider, uid: auth.uid) ||
        new
    end
  end
end
