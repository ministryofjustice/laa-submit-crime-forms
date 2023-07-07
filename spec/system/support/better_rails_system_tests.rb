# frozen_string_literal: true

module BetterRailsSystemTests
  # Use relative path in screenshot message to make it clickable in VS Code when running in Docker
  def image_path
    Pathname.new(absolute_image_path).relative_path_from(Rails.root).to_s
  end

  # Make failure screenshots compatible with multi-session setup
  def take_screenshot
    return super unless Capybara.last_used_session
    Capybara.using_session(Capybara.last_used_session) { super }
  end

  # Convert dom_id to selector
  def dom_id(*args)
    "##{super}"
  end
end

RSpec.configure do |config|
  # Add #dom_id support
  config.include ActionView::RecordIdentifier, type: :system
  config.include BetterRailsSystemTests, type: :system

  # Make urls in mailers contain the correct server host
  config.around(:each, type: :system, javascript: true) do |ex|
    was_host, Rails.application.default_url_options[:host] = Rails.application.default_url_options[:host], Capybara.server_host
    ex.run
    Rails.application.default_url_options[:host] = was_host
  end

  # we do this first as it is a prepend meaning this will run last and take priority
  config.prepend_before(:each, type: :system, javascript: true) do
    # Use JS driver always
    driven_by Capybara.javascript_driver
  end
  # Use the faster rack test by default for system specs if possible
  config.prepend_before(:each, type: :system) { driven_by :rack_test }
end