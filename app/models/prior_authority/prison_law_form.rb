module PriorAuthority
  class PrisonLawForm < PriorAuthorityApplication
    validates :prison_law, inclusion: { in: [true, false] }
  end
end
