require 'rails_helper'

RSpec.describe Steps::FirmDetails::FirmOfficeForm do
  subject(:form) { described_class.new(application:, **arguments) }

  let(:arguments) do
    {
      name:,
      account_number:,
      address_line_1:,
      address_line_2:,
      town:,
      postcode:,
    }
  end

  let(:application) do
    instance_double(Claim)
  end

  let(:name) { 'Lawyer 1' }
  let(:account_number) { 'ac1' }
  let(:address_line_1) { 'home' }
  let(:address_line_2) { 'homely' }
  let(:town) { 'hometown' }
  let(:postcode) { 'AA1 1AA' }

  describe '#valid?' do
    context 'when all fields are set' do
      it 'is valid' do
        expect(form).to be_valid
      end
    end

    %i[name account_number address_line_1 town postcode].each do |field|
      context "when #{field} is missing" do
        let(field) { nil }

        it 'has is a validation error on the field' do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(field, :blank)).to be(true)
        end
      end
    end

    context 'when address_line_2 is missing' do
      let(:address_line_2) { nil }

      it 'is valid' do
        expect(form).to be_valid
      end
    end
  end

  describe 'save!' do
    let!(:application) { Claim.create!(office_code: 'AAA', firm_office: firm_office) }
    let(:firm_office) { nil }

    context 'when application has an existing firm_office' do
      context 'and firm_office details have changed' do
        let(:firm_office) { FirmOffice.new(arguments.merge(name: 'Other')) }

        it 'creates a new firm_office record' do
          expect { subject.save! }.to change(FirmOffice, :count).by(1)
                                                                .and(change { application.reload.firm_office_id })
        end
      end

      context 'and firm_office detail have not changed' do
        let(:firm_office) { FirmOffice.new(arguments) }

        it 'does nothing' do
          expect { subject.save! }.not_to change(FirmOffice, :count)
        end
      end
    end

    context 'when application has no firm_office but one exists for the the account number' do
      context 'and firm_office details have changed' do
        before { FirmOffice.create!(arguments.merge(name: 'Other')) }

        it 'creates a new firm_office record' do
          expect { subject.save! }.to change(FirmOffice, :count).by(1)
                                                                .and(change { application.reload.firm_office_id })
        end
      end

      context 'and firm_office detail have not changed' do
        before { FirmOffice.create!(arguments) }

        it 'does nothing' do
          expect { subject.save! }.not_to change(FirmOffice, :count)
        end
      end

      context 'it matches a historic firm_office details' do
        before do
          old_firm_office = travel_to(1.day.ago) { FirmOffice.create!(arguments) }
          FirmOffice.create!(arguments.merge(name: 'Other', previous: old_firm_office))
        end

        it 'create a new firm_office record' do
          expect { subject.save! }.to change(FirmOffice, :count).by(1)
                                                                .and(change { application.reload.firm_office_id })
        end
      end
    end

    context 'when application has no firm_office and non exist for the the reference code' do
      it 'creates a new firm_office record' do
        expect { subject.save! }.to change(FirmOffice, :count).by(1)
                                                              .and(change { application.reload.firm_office_id })
      end
    end
  end
end
