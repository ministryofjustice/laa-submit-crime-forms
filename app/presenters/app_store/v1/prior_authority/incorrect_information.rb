module AppStore
  module V1
    module PriorAuthority
      class IncorrectInformation < AppStore::V1::Base
        attribute :information_requested, :string
        attribute :requested_at, :datetime
        attribute :sections_changed

        alias prior_authority_application parent
      end
    end
  end
end
