module Nsm
  module Steps
    class SupplementalClaimController < ApplicationController
      def show
        @record_id = params[:claim_id] == StartPage::NEW_RECORD ? StartPage::NEW_RECORD : params[:claim_id]
      end
    end
  end
end
