class ProviderSolicitor < ApplicationRecord
  EMAIL_REGEX = /\A[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-z](2,4)\Z/i

  validates :email, presence: true,
                              length: {maximum: 100},
                              uniqueness: true,
                              confirmation: true

end
