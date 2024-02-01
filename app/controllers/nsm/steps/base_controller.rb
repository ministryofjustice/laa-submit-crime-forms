module Nsm
  module Steps
    class BaseController < ::Steps::BaseStepController
      private

      def service
        Providers::Gatekeeper::NSM
      end
    end
  end
end
