# frozen_string_literal: true

module RailsSystemTestExtensions
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
  config.include RailsSystemTestExtensions, type: :system

  # Make urls in mailers contain the correct server host
  config.around(:each, :javascript, type: :system) do |ex|
    was_host = Rails.application.default_url_options[:host]
    Rails.application.default_url_options[:host] = Capybara.server_host
    ex.run
    Rails.application.default_url_options[:host] = was_host
  end

  config.before(:each, :javascript, type: :system) do
    # Use JS driver
    driven_by Capybara.javascript_driver do |options|
      options.browser_version = '133.0.6943.141'
    end
  end

  config.before(:each, type: :system) do
    allow(Clamby).to receive(:safe?).and_return(true)
  end
end
