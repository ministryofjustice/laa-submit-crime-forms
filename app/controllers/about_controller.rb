# frozen_string_literal: true

class AboutController < ApplicationController
  skip_before_action :authenticate_provider!
  layout 'submit_a_crime_form'

  def contact; end
end
