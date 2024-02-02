# frozen_string_literal: true

require 'clamby'

def clamd_config_file
  filename = ENV.fetch('CLAMD_CONF_FILENAME', 'clamd.local.conf')
  File.join(File.dirname(__FILE__), '..', 'clamd', filename)
end

Clamby.configure(
  {
    check: true,
    daemonize: true,
    config_file: clamd_config_file,
    output_level: 'high',
    fdpass: true,
    stream: true,
    error_clamscan_missing: !Rails.env.test?,
    error_clamscan_client_error: !Rails.env.test?,
    error_file_missing: true,
  }
)
