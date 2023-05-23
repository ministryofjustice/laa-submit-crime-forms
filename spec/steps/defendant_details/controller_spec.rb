require 'rails_helper'

RSpec.describe Steps::DefendantDetailsController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::DefendantsDetailsForm, Decisions::SimpleDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::DefendantsDetailsForm

  describe 'deleting a defendant' do
    let(:application) { Claim.create!(office_code: 'AAAA', defendants: defendants) }
    let(:defendants) { [main_defendant, additional_defendant] }

    let(:main_defendant) { Defendant.new(full_name: 'Jake', maat: 'AA1', position: '1') }
    let(:additional_defendant) { Defendant.new(full_name: 'Jim', maat: 'BB1', position: '2') }

    let(:params) do
      {
        'id' => application.id,
        'steps_defendants_details_form' => {
          'defendants_attributes' => {
            '0' => main_defendant.attributes,
            '1' => { 'id' => additional_defendant.id, '_destroy' => '1' }
          }
        }
      }
    end

    it 'will remove the defenant record from the DB' do
      put(:update, params:)

      expect(application.reload.defendants).to eq([main_defendant])
      expect(response).to redirect_to(edit_steps_defendant_details_path(application.id))
    end
  end

  describe 'adding a defendant' do
    let(:application) { Claim.create!(office_code: 'AAAA', defendants: defendants) }
    let(:defendants) { [main_defendant] }

    let(:main_defendant) { Defendant.new(full_name: 'Jake', maat: 'AA1', position: '1') }
    let(:params) do
      {
        'add_defendant' => true,
        'id' => application.id,
        'steps_defendants_details_form' => {
          'defendants_attributes' => {
            '0' => main_defendant.attributes,
          }
        }
      }
    end

    it 'adds a new blank defendant' do
      put(:update, params:)

      expect(application.reload.defendants).to contain_exactly(main_defendant,
                                                               have_attributes(full_name: nil, maat: nil, position: 2))
      expect(response).to redirect_to(edit_steps_defendant_details_path(application.id))
    end
  end
end
