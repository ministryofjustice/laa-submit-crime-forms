module PriorAuthority
  class OfficesController < ::OfficesController
    def edit_path
      edit_prior_authority_office_path
    end

    def post_save_path
      prior_authority_applications_path
    end

    def update_path
      prior_authority_office_path
    end
  end
end
