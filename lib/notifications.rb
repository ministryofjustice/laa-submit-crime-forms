class Notifications
  include Singleton

  attr_reader :config, :env_name

  def initialize
    @env_name = HostEnv.env_name

    @config = YAML.load(
      ERB.new(config_file).result
    ).fetch('notifications', {}).with_indifferent_access.freeze
  end

  private

  def config_file
    Rails.root.join('config/notifications.yml').read
  end
end
