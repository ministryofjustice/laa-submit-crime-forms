require 'rails_helper'

RSpec.describe CheckAnswers::EvidenceUploadsCard do
  subject { described_class.new(claim) }

  let(:claim) { instance_double(Claim, supporting_evidence:, send_by_post:) }
  let(:supporting_evidence) { [first_evidence, second_evidence] }
  let(:send_by_post) { false }
  let(:first_evidence) do
    { file_name: 'Defendant Report.pdf' }
  end
  let(:second_evidence) do
    { file_name: 'Offences.pdf' }
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
              head_key: 'send_by_post',
              text: 'No',
            },
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

    context 'No evidence files and send by post true' do
      let(:supporting_evidence) { [] }
      let(:send_by_post) { true }

      it 'generates section without any information inside' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'send_by_post',
              text: 'Yes',
            }
          ]
        )
      end
    end

    context 'No evidence files and send by post not set' do
      let(:supporting_evidence) { [] }
      let(:send_by_post) { nil }

      it 'generates section without any information inside' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'send_by_post',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>',
            }
          ]
        )
      end
    end
  end
end
