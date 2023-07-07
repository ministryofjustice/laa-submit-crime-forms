# frozen_string_literal: true

module SessionHelpers
  def within_session(...)
    Capybara.using_session(...)
  end
end

RSpec.configure do |config|
  config.include SessionHelpers, type: :system
end