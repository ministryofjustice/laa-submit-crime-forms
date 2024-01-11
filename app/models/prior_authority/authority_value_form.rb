module PriorAuthority
  class AuthorityValueForm < PriorAuthorityApplication
    attribute :less_than_five_hundred, :boolean
    validates :less_than_five_hundred, inclusion: { in: [true, false] }
  end
end
