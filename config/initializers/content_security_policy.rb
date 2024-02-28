# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data
    policy.object_src  :none

    # If there are any un-nonceable scripts that need to be added to the page, add their SHAs here in the format
    # policy.script_src  "'sha256-<sha 1 here>'", "'sha256-<sha 2 here>'", :self, :https, :report_sample
    policy.script_src  :self, :https, :report_sample

    # If there are any un-nonceable styles that need to be added to the page, add their SHAs here in the format
    # policy.style_src  "'sha256-<sha 1 here>'", "'sha256-<sha 2 here>'", :self, :https, :report_sample
    policy.style_src :self, :https, :report_sample

    # Sentry creates workers from "blobs" in order to report on errors, so we allow that
    policy.worker_src :blob
  end

  # Generate session nonces for permitted importmap and inline scripts
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w[script-src style-src]
end
