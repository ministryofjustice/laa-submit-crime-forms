module Assess
  module Uplift
    class WorkItemsForm < BaseForm
      SCOPE = 'work_items'.freeze

      class Remover < Uplift::RemoverForm
        LINKED_CLASS = V1::WorkItem
      end
    end
  end
end
