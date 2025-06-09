require 'rails_helper'

RSpec.describe PriorAuthority::Tasks::CaseAndHearingDetail, type: :presenter do
  subject(:presenter) { described_class.new(application:) }

  let(:application) { create(:prior_authority_application, prison_law:) }
  let(:prison_law) { false }

  describe '#path' do
    subject(:path) { presenter.path }

    context 'when application is a prison law matter' do
      let(:prison_law) { true }

      it { is_expected.to eq("/prior-authority/applications/#{application.id}/steps/next_hearing") }
    end

    context 'when application is not prison law matter' do
      let(:prison_law) { false }

      it { is_expected.to eq("/prior-authority/applications/#{application.id}/steps/case_detail") }
    end
  end

  describe '#not_applicable?' do
    it { is_expected.not_to be_not_applicable }
  end

  describe '#can_start?' do
    context 'when Ufn task has been completed' do
      before do
        application.update!(
          ufn: '111111/111',
          viewed_steps: ['ufn'],
        )
      end

      it { is_expected.to be_can_start }
    end

    context 'when Ufn task has not been completed' do
      before do
        application.update!(
          ufn: nil,
          viewed_steps: []
        )
      end

      it { is_expected.not_to be_can_start }
    end
  end

  describe '#completed?' do
    before do
      klass = PriorAuthority::Steps::NextHearingForm
      allow(klass).to receive(:build).and_return(instance_double(klass, validate: next_hearing_valid))
      klass = PriorAuthority::Steps::CaseDetailForm
      allow(klass).to receive(:build).and_return(instance_double(klass, validate: case_detail_valid))
      klass = PriorAuthority::Steps::HearingDetailForm
      allow(klass).to receive(:build).and_return(instance_double(klass, validate: hearing_detail_valid))
      klass = PriorAuthority::Steps::PsychiatricLiaisonForm
      allow(klass).to receive(:build).and_return(instance_double(klass, validate: psychiatric_liaison_valid))
      klass = PriorAuthority::Steps::YouthCourtForm
      allow(klass).to receive(:build).and_return(instance_double(klass, validate: youth_court_valid))
    end

    context 'when all requisite forms are valid for prison law flow' do
      let(:prison_law) { true }
      let(:next_hearing_valid) { true }
      let(:case_detail_valid) { false }
      let(:hearing_detail_valid) { false }
      let(:youth_court_valid) { false }
      let(:psychiatric_liaison_valid) { false }

      it { is_expected.to be_completed }
    end

    context 'when all requisite forms are valid for magistrates court' do
      before { allow(application).to receive(:court_type).and_return('magistrates_court') }

      let(:next_hearing_valid) { false }
      let(:case_detail_valid) { true }
      let(:hearing_detail_valid) { true }
      let(:youth_court_valid) { true }
      let(:psychiatric_liaison_valid) { false }

      it { is_expected.to be_completed }
    end

    context 'when all requisite forms are valid for central criminal court' do
      before { allow(application).to receive(:court_type).and_return('central_criminal_court') }

      let(:next_hearing_valid) { false }
      let(:case_detail_valid) { true }
      let(:hearing_detail_valid) { true }
      let(:youth_court_valid) { false }
      let(:psychiatric_liaison_valid) { true }

      it { is_expected.to be_completed }
    end

    context 'when all requisite forms are valid for crown court' do
      before { allow(application).to receive(:court_type).and_return('crown_court') }

      let(:next_hearing_valid) { false }
      let(:case_detail_valid) { true }
      let(:hearing_detail_valid) { true }
      let(:youth_court_valid) { false }
      let(:psychiatric_liaison_valid) { false }

      it { is_expected.to be_completed }
    end

    context 'when one or more requisite forms are invalid' do
      let(:next_hearing_valid) { false }
      let(:case_detail_valid) { true }
      let(:hearing_detail_valid) { false }
      let(:youth_court_valid) { false }
      let(:psychiatric_liaison_valid) { false }

      it { is_expected.not_to be_completed }
    end

    context 'when psychiatric liaison not complete for a central criminal court matter' do
      before { allow(application).to receive(:court_type).and_return('central_criminal_court') }

      let(:next_hearing_valid) { false }
      let(:case_detail_valid) { true }
      let(:hearing_detail_valid) { true }
      let(:youth_court_valid) { false }
      let(:psychiatric_liaison_valid) { false }

      it { is_expected.not_to be_completed }
    end

    context 'when youth court not complete for a magistrates court matter' do
      before { allow(application).to receive(:court_type).and_return('magistrates_court') }

      let(:next_hearing_valid) { false }
      let(:case_detail_valid) { true }
      let(:hearing_detail_valid) { true }
      let(:youth_court_valid) { false }
      let(:psychiatric_liaison_valid) { false }

      it { is_expected.not_to be_completed }
    end
  end
end
