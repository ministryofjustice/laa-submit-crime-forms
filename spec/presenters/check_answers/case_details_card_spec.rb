require 'rails_helper'

RSpec.describe CheckAnswers::CaseDetailsCard do
  subject { described_class.new(claim) }

  let(:claim) { instance_double(Claim) }
  let(:form) do
    instance_double(Steps::CaseDetailsForm, main_offence:, main_offence_date:,
    assigned_counsel:, unassigned_counsel:, agent_instructed:, remitted_to_magistrate:)
  end
  let(:main_offence) { 'Theft' }
  let(:main_offence_date) { Date.new(2023, 1, 1) }
  let(:assigned_counsel) { YesNoAnswer::YES }
  let(:unassigned_counsel) { YesNoAnswer::NO }
  let(:agent_instructed) { YesNoAnswer::NO }
  let(:remitted_to_magistrate) { YesNoAnswer::NO }

  before do
    allow(Steps::CaseDetailsForm).to receive(:build).and_return(form)
  end

  describe '#initialize' do
    it 'creates the data instance' do
      subject
      expect(Steps::CaseDetailsForm).to have_received(:build).with(claim)
    end
  end

  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Case Details')
    end
  end

  describe '#route_path' do
    it 'is correct route' do
      expect(subject.route_path).to eq('case_details')
    end
  end

  describe '#row_data' do
    it 'generates case detail rows' do
      expect(subject.row_data[:main_offence][:text]).to eq('Theft')
      expect(subject.row_data[:main_offence_date][:text]).to eq('01 January 2023')
      expect(subject.row_data[:assigned_counsel][:text]).to eq('Yes')
      expect(subject.row_data[:unassigned_counsel][:text]).to eq('No')
      expect(subject.row_data[:agent_instructed][:text]).to eq('No')
      expect(subject.row_data[:remitted_to_magistrate][:text]).to eq('No')
    end
  end
end
