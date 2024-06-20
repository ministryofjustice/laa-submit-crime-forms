# frozen_string_literal: true

class AboutController < ApplicationController
  skip_before_action :authenticate_provider!
  skip_before_action :can_access_service
  layout 'submit_a_crime_form'

  def contact; end
end
