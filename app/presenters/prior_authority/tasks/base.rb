module PriorAuthority
  module Tasks
    class Base < ::Tasks::Generic
      def default_url_options
        { application_id: application }
      end
    end
  end
end
