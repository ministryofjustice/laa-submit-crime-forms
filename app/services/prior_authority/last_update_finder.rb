module PriorAuthority
  class LastUpdateFinder
    def self.call(application)
      new(application).call
    end

    attr_reader :application

    def initialize(application)
      @application = application
    end

    def call
      updates_at.max
    end

    private

    def updates_at
      @updates_at ||= [application.updated_at] + updated_associations
    end

    def updated_associations
      updated_associations = []
      associations = PriorAuthorityApplication.reflect_on_all_associations

      associations.each_with_object(updated_associations) do |association, arr|
        next if excluded?(association.name)

        arr << updated_ats_for(association.name)
      end

      updated_associations.flatten.compact
    end

    def updated_ats_for(association_name)
      if application.send(association_name).respond_to?(:pluck)
        application.send(association_name).pluck(:updated_at)
      else
        application.send(association_name).updated_at
      end
    end

    # TODO: CRM457-1192 exclude further_information[_request]s association when it exists
    def excluded?(association_name)
      association_name.in?(%i[provider])
    end
  end
end
