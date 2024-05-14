require 'rails_helper'

RSpec.describe Nsm::SupportingEvidence::CheckList do
  subject(:presenter) { described_class.new(claim) }

  let(:claim) { create(:claim, :complete, :one_other_disbursement) }

  it { is_expected.to respond_to(:items) }

  describe '#render' do
    subject(:content) { presenter.render }

    context 'with assigned counsel' do
      before { claim.assigned_counsel = 'yes' }

      it 'includes CRM8 form' do
        expect(content)
          .to include(
            '<li>' \
            '<a class="govuk-link govuk-link--no-visited-state" ' \
            'target="_blank" ' \
            'href="https://www.gov.uk/government/publications/crm8-assigned-counsels-fee-note">' \
            'CRM8 form</a>' \
            '</li>'
          )
      end
    end

    context 'without assigned counsel' do
      before { claim.assigned_counsel = 'no' }

      it { is_expected.not_to include('CRM8') }
    end

    context 'with remittal' do
      before { claim.remitted_to_magistrate = 'yes' }

      it { is_expected.to include('<li>evidence of remittal</li>') }
    end

    context 'without remittal' do
      before { claim.remitted_to_magistrate = 'no' }

      it { is_expected.not_to include('remittal') }
    end

    context 'with supplemental claim' do
      before { claim.supplemental_claim = 'yes' }

      it { is_expected.to include('<li>evidence of supplemental claim</li>') }
    end

    context 'without supplemental claim' do
      before { claim.supplemental_claim = 'no' }

      it { is_expected.not_to include('supplemental claim') }
    end

    context 'with disbursement with prior authority' do
      before { claim.disbursements.first.update!(prior_authority: 'yes') }

      it { is_expected.to include('<li>prior authority certification</li>') }
    end

    context 'without disbursement with prior authority' do
      before { claim.disbursements.map { |d| d.update!(prior_authority: 'no') } }

      it { is_expected.not_to include('prior authority') }
    end

    context 'without disbursement' do
      before { claim.disbursements.destroy_all }

      it { is_expected.not_to include('prior authority') }
    end
  end
end
