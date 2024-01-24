require 'rails_helper'

RSpec.describe PriorAuthority::Tasks::CaseAndHearingDetail, type: :presenter do
  subject(:presenter) { described_class.new(application:) }

  let(:application) { create(:prior_authority_application) }

  describe '#path' do
    subject(:path) { presenter.path }

    it { is_expected.to eq("/prior-authority/applications/#{application.id}/steps/case_detail") }
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

  describe '#completed?' do
    before do
      klass = PriorAuthority::Steps::CaseDetailForm
      allow(klass).to receive(:build).and_return(instance_double(klass, valid?: case_detail_valid))
      klass = PriorAuthority::Steps::HearingDetailForm
      allow(klass).to receive(:build).and_return(instance_double(klass, valid?: hearing_detail_valid))
    end

    context 'when all requisite forms are valid' do
      let(:case_detail_valid) { true }
      let(:hearing_detail_valid) { true }

      it { is_expected.to be_completed }
    end

    context 'when one or more requisite forms are invalid' do
      let(:case_detail_valid) { false }
      let(:hearing_detail_valid) { true }

      it { is_expected.not_to be_completed }
    end
  end
end
