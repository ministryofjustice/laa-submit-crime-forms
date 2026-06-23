return unless defined?(Flatware)

ENV['PGGSSENCMODE'] = 'disable'
ENV['RAILS_ENV'] ||= 'test'

Flatware.configure do |conf|
  conf.before_fork do
    require File.expand_path('../config/environment', __dir__)
    ActiveRecord::Base.connection.disconnect!
  end

  conf.after_fork do |test_env_number|
    SimpleCov.at_fork.call(test_env_number)

    config = ActiveRecord::Base.connection_db_config.configuration_hash

    ActiveRecord::Base.establish_connection(
      config.merge(
        database: config.fetch(:database) + test_env_number.to_s
      )
    )
  end
end
