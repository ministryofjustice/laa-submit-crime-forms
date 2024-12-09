module AppStore
  module V1
    module Nsm
      class DisbursementCollection < AppStore::V1::Collection
        def by_age
          order(:disbursement_date)
        end
      end
    end
  end
end
