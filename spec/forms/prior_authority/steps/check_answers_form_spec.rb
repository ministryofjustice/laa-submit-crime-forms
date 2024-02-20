require 'rails_helper'

RSpec.describe PriorAuthority::Steps::CheckAnswersForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      confirm_excluding_vat:,
      confirm_travel_expenditure:,
    }
  end

  describe '#validate' do
    let(:application) { instance_double(PriorAuthorityApplication) }

    context 'with all confirmations accepted' do
      let(:confirm_excluding_vat) { 'true' }
      let(:confirm_travel_expenditure) { 'true' }

      it { is_expected.to be_valid }
    end

    context 'with confirm_excluding_vat not accepted' do
      let(:confirm_excluding_vat) { 'false' }
      let(:confirm_travel_expenditure) { 'true' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:confirm_excluding_vat, :accepted)).to be(true)
        expect(form.errors.messages[:confirm_excluding_vat])
          .to include('Select if you confirm that all costs are exclusive of VAT')
      end
    end

    context 'with confirm_travel_expenditure not accepted' do
      let(:confirm_excluding_vat) { 'true' }
      let(:confirm_travel_expenditure) { 'false' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:confirm_travel_expenditure, :accepted)).to be(true)
        expect(form.errors.messages[:confirm_travel_expenditure])
          .to include(
            'Select if you confirm that any travel expenditure (such as mileage, ' \
            'parking and travel fares) is included as additional items in the primary ' \
            'quote, and is not included as part of any hourly rate'
          )
      end
    end
  end

  describe '#save' do
    subject(:save) { form.save }

    let(:application) { create(:prior_authority_application) }

    context 'with all confirmations accepted' do
      let(:confirm_excluding_vat) { 'true' }
      let(:confirm_travel_expenditure) { 'true' }

      it 'persists the value' do
        expect { save }.to change { application.reload.attributes }
          .from(
            hash_including(
              'confirm_excluding_vat' => nil,
              'confirm_travel_expenditure' => nil,
            )
          )
          .to(
            hash_including(
              'confirm_excluding_vat' => true,
              'confirm_travel_expenditure' => true,
            )
          )
      end
    end

    context 'with unaccepted confirmations' do
      let(:confirm_excluding_vat) { false }
      let(:confirm_travel_expenditure) { false }

      it 'does not persist the case details' do
        expect { save }.not_to change { application.reload.attributes }
          .from(
            hash_including(
              'confirm_excluding_vat' => nil,
              'confirm_travel_expenditure' => nil,
            )
          )
      end
    end

    context 'with nil confirmations' do
      let(:confirm_excluding_vat) { nil }
      let(:confirm_travel_expenditure) { nil }

      it 'does not persist the case details' do
        expect { save }.not_to change { application.reload.attributes }
          .from(
            hash_including(
              'confirm_excluding_vat' => nil,
              'confirm_travel_expenditure' => nil,
            )
          )
      end
    end
  end
end
