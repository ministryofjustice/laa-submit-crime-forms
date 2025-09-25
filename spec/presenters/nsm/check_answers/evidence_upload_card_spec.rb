require 'rails_helper'

RSpec.describe Nsm::CheckAnswers::EvidenceUploadsCard do
  subject { described_class.new(claim) }

  let(:claim) { instance_double(Claim, supporting_evidence:, send_by_post:) }
  let(:supporting_evidence) { [first_evidence, second_evidence] }
  let(:send_by_post) { false }
  let(:first_evidence) do
    { id: 'test', file_name: 'Defendant Report.pdf' }
  end
  let(:second_evidence) do
    { id: 'test', file_name: 'Offences.pdf' }
  end

  before do
    allow(claim).to receive(:gdpr_documents_deleted?).and_return(false)
  end

  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Upload supporting evidence')
    end
  end

  describe '#row_data' do
    context 'when postal_evidence feature flag is enabled' do
      before do
        allow(FeatureFlags).to receive(:postal_evidence).and_return(double(:postal_evidence, enabled?: true))
      end

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
                href: '/downloads/test?file_name=Defendant+Report.pdf',
                text: 'Defendant Report.pdf',
                head_opts: { count: 1 }
              },
              {
                head_key: 'supporting_evidence',
                href: '/downloads/test?file_name=Offences.pdf',
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

    context 'when postal_evidence feature flag is disabled' do
      before do
        allow(FeatureFlags).to receive(:postal_evidence).and_return(double(:postal_evidence, enabled?: false))
      end

      context '2 evidence files' do
        it 'generates section with 2 indexed filenames' do
          expect(subject.row_data).to eq(
            [
              {
                head_key: 'supporting_evidence',
                href: '/downloads/test?file_name=Defendant+Report.pdf',
                text: 'Defendant Report.pdf',
                head_opts: { count: 1 }
              },
              {
                head_key: 'supporting_evidence',
                 href: '/downloads/test?file_name=Offences.pdf',
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
            []
          )
        end
      end
    end
  end

  describe '#custom' do
    context 'when gdpr_documents_deleted is true' do
      before do
        allow(claim).to receive(:gdpr_documents_deleted?).and_return(true)
      end

      it 'returns the GDPR deleted partial' do
        expect(subject.custom).to eq({ partial: 'nsm/steps/view_claim/gdpr_uploaded_files_deleted' })
      end
    end

    context 'when gdpr_documents_deleted is false' do
      before do
        allow(claim).to receive(:gdpr_documents_deleted?).and_return(false)
      end

      it 'returns nil' do
        expect(subject.custom).to be_nil
      end
    end
  end
end
