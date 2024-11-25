module AppStore
  module V1
    module Nsm
      class WorkItemCollection < AppStore::V1::Collection
        def changed_work_type
          WorkItemCollection.new(select { _1.work_type != _1.assessed_work_type })
        end
      end
    end
  end
end
