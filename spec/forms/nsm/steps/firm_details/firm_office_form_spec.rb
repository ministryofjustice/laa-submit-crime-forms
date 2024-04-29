require 'rails_helper'

RSpec.describe Nsm::Steps::FirmDetails::FirmOfficeForm do
  subject(:form) { described_class.new(application:, **arguments) }

  let(:arguments) do
    {
      name:,
      address_line_1:,
      address_line_2:,
      town:,
      postcode:,
      vat_registered:
    }
  end

  let(:application) do
    instance_double(Claim)
  end

  let(:name) { 'Lawyer 1' }
  # rubocop:disable RSpec/IndexedLet
  let(:address_line_1) { 'home' }
  let(:address_line_2) { 'homely' }
  # rubocop:enable RSpec/IndexedLet
  let(:town) { 'hometown' }
  let(:postcode) { 'AA1 1AA' }
  let(:vat_registered) { 'yes' }

  describe '#valid?' do
    context 'when all fields are set' do
      it 'is valid' do
        expect(form).to be_valid
      end
    end

    %i[name address_line_1 town postcode vat_registered].each do |field|
      context "when #{field} is missing" do
        let(field) { nil }

        it 'has a validation error on the field' do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(field, :blank)).to be(true)
        end
      end
    end

    context 'when postcode is invalid' do
      let(:postcode) { 'AAA' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:postcode, :invalid)).to be(true)
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
    let!(:application) { create(:claim, firm_office:) }
    let(:firm_office) { nil }

    context 'when application has an existing firm_office' do
      context 'and firm_office details have changed' do
        let(:firm_office) { FirmOffice.new(arguments.merge(name: 'Other')) }

        it 'updates the firm_office record' do
          expect { subject.save! }.to change { application.reload.firm_office.name }.from('Other').to('Lawyer 1')
        end
      end
    end

    context 'when application has no firm_office' do
      context 'and firm_office details have been added' do
        it 'creates a new firm_office record' do
          expect { subject.save! }.to change(FirmOffice, :count).by(1)
                                                                .and(change { application.reload.firm_office_id })
        end
      end
    end
  end
end
