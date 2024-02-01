require 'rails_helper'

# These specs will not run unless the `INCLUDE_ACCESSIBILITY_SPECS` env var is set
RSpec.describe 'Accessibility', :accessibility do
  subject { page }

  before do
    driven_by(:headless_chrome)
    visit provider_saml_omniauth_callback_path
  end

  let(:provider) { create(:provider) }
  let(:application) { create(:prior_authority_application) }
  let(:claim) { create(:claim) }
  let(:be_axe_clean_with_caveats) do
    # Ignoring known false positive around skip links, see: https://design-system.service.gov.uk/components/skip-link/#when-to-use-this-component
    # Ignoring known false positive around aria-expanded attributes on conditional reveal radios, see: https://github.com/alphagov/govuk-frontend/issues/979
    be_axe_clean.excluding('.govuk-skip-link')
                .skipping('aria-allowed-attr')
  end

  context 'when viewing general screenss' do
    %i[root].each do |path|
      describe "#{path} screen" do
        before do
          visit send(:"#{path}_path")
        end

        it 'is accessible' do
          expect(page).to(be_axe_clean_with_caveats)
        end
      end
    end
  end
end
