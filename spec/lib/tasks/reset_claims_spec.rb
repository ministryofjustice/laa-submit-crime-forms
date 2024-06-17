require 'rails_helper'

describe 'reset_data:', type: :task do
  describe 'claims' do
    subject { Rake::Task['reset_data:claims'].execute }

    let(:dummy_submitter) { instance_double(SubmitToAppStore) }

    before do
      Rails.application.load_tasks if Rake::Task.tasks.empty?
      allow(SubmitToAppStore).to receive(:new).and_return(dummy_submitter)
      allow(dummy_submitter).to receive(:perform)
    end

    context 'in production' do
      before { allow(HostEnv).to receive(:production?).and_return(true) }

      it { expect { subject }.to raise_error 'NEVER do this with real-life data' }
    end

    context 'when there is a draft claim' do
      let(:claim) { create(:claim, :complete, status: :draft) }

      before { claim }

      it 'does not call the app store' do
        subject
        expect(dummy_submitter).not_to have_received(:perform)
        expect(claim.reload).to be_draft
      end
    end

    context 'when there is a submitted claim' do
      let(:claim) { create(:claim, :complete, status: :submitted) }

      before { claim }

      it 'resubmits it' do
        subject
        expect(dummy_submitter).to have_received(:perform).with(submission: claim)
        expect(claim.reload).to be_submitted
      end
    end

    context 'when there is an assessed claim' do
      let(:claim) do
        create(:claim,
               :complete,
               status: :part_grant,
               assessment_comment: 'Only allowing some of this',
               allowed_letters: 1,
               allowed_letters_uplift: 10,
               letters_adjustment_comment: 'Reducing this',
               allowed_calls: 1,
               allowed_calls_uplift: 11,
               calls_adjustment_comment: 'Reducing this',
               work_items: [work_item],
               disbursements: [disbursement])
      end

      let(:work_item) do
        build(:work_item,
              allowed_time_spent: 100,
              allowed_uplift: 80,
              adjustment_comment: 'Reducing this')
      end

      let(:disbursement) do
        build(:disbursement,
              allowed_total_cost_without_vat: 10.3,
                allowed_miles: 10.4,
                allowed_apply_vat: 'yes',
                allowed_vat_amount: 11.2,
                adjustment_comment: 'Reducing this')
      end

      before { claim }

      it 'resets and resubmits it' do
        subject
        expect(dummy_submitter).to have_received(:perform).with(submission: claim)
        expect(claim.reload).to have_attributes(
          status: 'submitted',
          assessment_comment: nil,
          allowed_letters: nil,
          allowed_letters_uplift: nil,
          letters_adjustment_comment: nil,
          allowed_calls: nil,
          allowed_calls_uplift: nil,
          calls_adjustment_comment: nil
        )

        expect(work_item.reload).to have_attributes(
          allowed_time_spent: nil,
          allowed_uplift: nil,
          adjustment_comment: nil
        )

        expect(disbursement.reload).to have_attributes(
          allowed_total_cost_without_vat: nil,
          allowed_miles: nil,
          allowed_apply_vat: nil,
          allowed_vat_amount: nil,
          adjustment_comment: nil
        )
      end
    end
  end
end
