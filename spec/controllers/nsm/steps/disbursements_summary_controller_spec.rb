require 'rails_helper'

RSpec.describe Nsm::Steps::DisbursementsController, type: :controller do
  context 'when some disbursements are incomplete' do
    let(:claim) { create(:claim, disbursements:) }
    let(:disbursements) do
      [
        build(:disbursement, :valid),
        build(:disbursement, :valid, disbursement_date: nil),
        build(:disbursement, :valid, disbursement_date: nil)
      ]
    end

    before do
      allow(controller).to receive(:current_application).and_return(claim)
    end

    it 'generates the correct error summary' do
      get :edit, params: { id: claim.id }
      expect(controller.instance_variable_get(:@items_incomplete_flash)[:default])
        .to include('2 disbursements are incomplete:')
    end

    it 'creates the correct link for incomplete disbursement' do
      incomplete_disbursements = claim.disbursements.reject(&:complete?).sort_by(&:position)
      get :edit, params: { id: claim.id }
      expect(controller.instance_variable_get(:@items_incomplete_flash)[:default])
        .to include("<a class=\"govuk-link\" href=\"/non-standard-magistrates/applications/#{claim.id}" \
                    "/steps/disbursement_type/#{incomplete_disbursements[0].id}\">item 1</a>")
      expect(controller.instance_variable_get(:@items_incomplete_flash)[:default])
        .to include("<a class=\"govuk-link\" href=\"/non-standard-magistrates/applications/#{claim.id}" \
                    "/steps/disbursement_type/#{incomplete_disbursements[1].id}\">item 2</a>")
    end
  end

  it_behaves_like 'a generic step controller', Steps::AddAnotherForm, Decisions::DecisionTree
  it_behaves_like 'a step that can be drafted', Steps::AddAnotherForm
end
