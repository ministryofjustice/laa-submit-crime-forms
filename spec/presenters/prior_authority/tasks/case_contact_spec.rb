require 'rails_helper'

RSpec.describe PriorAuthority::Tasks::CaseContact, type: :presenter do
  subject(:presenter) { described_class.new(application:) }

  let(:application) { create(:prior_authority_application) }

  describe '#path' do
    subject(:path) { presenter.path }

    it { is_expected.to eq("/prior-authority/applications/#{application.id}/steps/case_contact") }
  end

  describe '#not_applicable?' do
    it { is_expected.not_to be_not_applicable }
  end

  describe '#can_start?' do
    context 'when Ufn task has been completed' do
      before do
        application.update!(
          ufn: '111111/111',
          navigation_stack: ["/prior-authority/applications/#{application.id}/steps/ufn"],
        )
      end

      it { is_expected.to be_can_start }
    end

    context 'when Ufn task has not been completed' do
      before do
        application.update!(
          ufn: nil,
          navigation_stack: []
        )
      end

      it { is_expected.not_to be_can_start }
    end
  end

  it_behaves_like 'a task with generic complete?', PriorAuthority::Steps::CaseContactForm
end
