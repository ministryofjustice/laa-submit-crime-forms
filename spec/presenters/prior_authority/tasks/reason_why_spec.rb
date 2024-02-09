require 'rails_helper'

RSpec.describe PriorAuthority::Tasks::ReasonWhy, type: :presenter do
  subject(:presenter) { described_class.new(application:) }

  let(:application) { build_stubbed(:prior_authority_application) }

  describe '#path' do
    subject(:path) { presenter.path }

    it { is_expected.to eq("/prior-authority/applications/#{application.id}/steps/reason_why") }
  end

  describe '#not_applicable?' do
    it { is_expected.not_to be_not_applicable }
  end

  describe '#can_start?' do
    it { is_expected.not_to be_can_start }

    context 'when about requets elements are enabled' do
      let(:application) { create(:prior_authority_application, :about_request_enabled) }

      it { is_expected.to be_can_start }
    end
  end

  it_behaves_like 'a task with generic complete?', PriorAuthority::Steps::ReasonWhyForm
end
