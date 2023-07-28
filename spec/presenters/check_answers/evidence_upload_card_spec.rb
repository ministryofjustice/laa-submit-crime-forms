require 'rails_helper'

RSpec.describe CheckAnswers::EvidenceUploadsCard do
  subject { described_class.new(claim) }

  let(:claim) { instance_double(Claim) }
  let(:evidence_list) { [first_evidence, second_evidence] }
  let(:first_evidence) do
    { file_name: 'Defendant Report.pdf' }
  end
  let(:second_evidence) do
    { file_name: 'Offences.pdf' }
  end
  let(:claim_id) { '529fc1bf-6f42-46b5-bfbc-01a4d27a7553' }

  before do
    allow(claim).to receive(:id).and_return(claim_id)
    allow(SupportingEvidence).to receive(:where).with({ claim_id: }).and_return(evidence_list)
  end

  describe '#initialize' do
    it 'creates the data instance' do
      subject
      expect(SupportingEvidence).to have_received(:where)
    end
  end

  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Upload supporting evidence')
    end
  end

  describe '#row_data' do
    context '2 evidence files' do
      it 'generates section with 2 indexed filenames' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'supporting_evidence',
              text: 'Defendant Report.pdf',
              head_opts: { count: 1 }
            },
            {
              head_key: 'supporting_evidence',
              text: 'Offences.pdf',
              head_opts: { count: 2 }
            }
          ]
        )
      end
    end

    context 'No evidence files' do
      let(:evidence_list) { [] }

      it 'generates section without any information inside' do
        expect(subject.row_data).to eq(
          []
        )
      end
    end
  end
end
