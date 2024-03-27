require 'rails_helper'

RSpec.describe PriorAuthority::Tasks::FurtherInformation, type: :presenter do
  subject(:presenter) { described_class.new(application:) }

  let(:application) { build_stubbed(:prior_authority_application) }

  describe '#path' do
    subject(:path) { presenter.path }

    it { is_expected.to eq("/prior-authority/applications/#{application.id}/steps/further_information") }
  end

  describe '#not_applicable?' do
    it { is_expected.not_to be_not_applicable }
  end

  describe '#can_start?' do
    it { is_expected.not_to be_can_start }

    context 'when about an application is complete' do
      before do
        allow(subject).to receive(:fulfilled?).with(PriorAuthority::Tasks::Ufn).and_return(true)
        allow(subject).to receive(:fulfilled?).with(PriorAuthority::Tasks::CaseContact).and_return(true)
        allow(subject).to receive(:fulfilled?).with(PriorAuthority::Tasks::ClientDetail).and_return(true)
        allow(subject).to receive(:fulfilled?).with(PriorAuthority::Tasks::CaseAndHearingDetail).and_return(true)
        allow(subject).to receive(:fulfilled?).with(PriorAuthority::Tasks::PrimaryQuote).and_return(true)
        allow(subject).to receive(:fulfilled?).with(PriorAuthority::Tasks::AlternativeQuotes).and_return(true)
        allow(subject).to receive(:fulfilled?).with(PriorAuthority::Tasks::ReasonWhy).and_return(true)
      end

      it { is_expected.to be_can_start }
    end
  end

  it_behaves_like 'a task with generic complete?', PriorAuthority::Steps::FurtherInformationForm
end
