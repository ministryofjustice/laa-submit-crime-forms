require 'rails_helper'

RSpec.describe Nsm::Steps::FirmDetailsForm do
  subject { described_class.new(params) }

  let(:params) do
    {
      'application' => application,
      'firm_office_attributes' => firm_office_attributes,
      'solicitor_attributes' => solicitor_attributes,
    }
  end
  let(:application) { instance_double(Claim, firm_office:, solicitor:) }
  let(:firm_office_attributes) { nil }
  let(:solicitor_attributes) { nil }
  let(:firm_office) { nil }
  let(:solicitor) { nil }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices
      ).to eq([
                YesNoAnswer::YES,
                YesNoAnswer::NO,
              ])
    end
  end

  describe '#initializing nested objects' do
    context 'form_office' do
      context 'when firm_office_attributes is passed in' do
        let(:firm_office_attributes) { { 'name' => 'Firm Name', 'postcode' => 'AA1 1AA' } }

        it 'used to set values' do
          expect(subject.firm_office).to have_attributes(
            name: 'Firm Name',
            address_line_1: nil,
            postcode: 'AA1 1AA'
          )
        end

        context 'with existing address in DB' do
          let(:firm_office) { instance_double(FirmOffice, attributes: { 'address_line_1' => 'home' }) }

          it 'ignores existing fields' do
            expect(subject.firm_office).to have_attributes(
              name: 'Firm Name',
              address_line_1: nil,
              postcode: 'AA1 1AA'
            )
          end
        end
      end

      context 'when firm_office_attributes is blank' do
        context 'with existing address in DB' do
          let(:firm_office) { instance_double(FirmOffice, attributes: { 'address_line_1' => 'home' }) }

          it 'populates the values from the DB' do
            expect(subject.firm_office).to have_attributes(
              name: nil,
              address_line_1: 'home',
              postcode: nil
            )
          end
        end

        context 'without an existing address in DB' do
          it 'leaves the fields blank' do
            expect(subject.firm_office).to have_attributes(
              name: nil,
              address_line_1: nil,
              postcode: nil
            )
          end
        end
      end
    end

    context 'solicitor' do
      context 'when solicitor_attributes is passed in' do
        let(:solicitor_attributes) { { 'first_name' => 'John' } }

        it 'used to set values' do
          expect(subject.solicitor).to have_attributes(
            first_name: 'John',
            reference_number: nil,
          )
        end

        context 'with existing record in DB' do
          let(:solicitor) { instance_double(Solicitor, attributes: { 'reference_number' => 'AAA1' }) }

          it 'ignores existing fields' do
            expect(subject.solicitor).to have_attributes(
              first_name: 'John',
              reference_number: nil,
            )
          end
        end
      end

      context 'when solicitor_attributes is blank' do
        context 'with existing record in DB' do
          let(:solicitor) { instance_double(Solicitor, attributes: { 'reference_number' => 'AAA1' }) }

          it 'populates the values from the DB' do
            expect(subject.solicitor).to have_attributes(
              first_name: nil,
              reference_number: 'AAA1',
            )
          end
        end

        context 'without an existing record in DB' do
          it 'leaves the fields blank' do
            expect(subject.solicitor).to have_attributes(
              first_name: nil,
              reference_number: nil,
            )
          end
        end
      end
    end
  end

  describe '#save!' do
    let(:firm_office_form) { double(:firm_office, save!: true) }
    let(:solicitor_form) { double(:solicitor, save!: true) }

    it 'call persist on the nested firm_office and solicitor objects' do
      allow(Nsm::Steps::FirmDetails::FirmOfficeForm).to receive(:new).and_return(firm_office_form)
      allow(Nsm::Steps::FirmDetails::SolicitorForm).to receive(:new).and_return(solicitor_form)

      subject.save!

      expect(firm_office_form).to have_received(:save!)
      expect(solicitor_form).to have_received(:save!)
    end
  end
end
