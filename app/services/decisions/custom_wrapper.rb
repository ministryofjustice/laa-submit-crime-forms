module Decisions
  class CustomWrapper < SimpleDelegator
    def first_invalid(scope, *forms)
      scope.detect { |record| forms.any? { |f| !f.build(record, application:).valid? } }
    end
  end
end
