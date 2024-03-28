module Nsm
  class OfficesController < ::OfficesController
    layout 'nsm'

    def edit_path
      edit_nsm_office_path
    end

    def post_save_path
      nsm_applications_path
    end

    def update_path
      nsm_office_path
    end
  end
end
