require 'rails_helper'

RSpec.describe Providers::OfficeRouter do
  include Rails.application.routes.url_helpers

  subject { described_class.call(provider) }

  let(:provider) { Provider.new(office_codes:, selected_office_code:) }
  let(:office_codes) { %w[ABC XYZ] }
  let(:selected_office_code) { nil }

  describe 'redirect path' do
    context 'when there is no selected office' do
      it { expect(subject).to eq(edit_nsm_steps_office_select_path) }
    end

    context 'when there is a selected office' do
      let(:selected_office_code) { 'ABC' }

      context 'and there are multiple offices' do
        it { expect(subject).to eq(edit_nsm_steps_office_confirm_path) }
      end

      context 'and there is only one office' do
        let(:office_codes) { %w[ABC] }

        it { expect(subject).to eq(nsm_applications_path) }
      end
    end
  end
end
