require 'rails_helper'

RSpec.describe PriorAuthority::Steps::CaseDetail::DefendantForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      maat:,
    }
  end

  describe '#validate' do
    let(:application) { instance_double(PriorAuthorityApplication) }

    context 'with valid MAAT ID number' do
      let(:maat) { '1234567' }

      it { is_expected.to be_valid }
    end

    context 'with a valid, hardcoded MAAT ID number' do
      let(:maat) { '900900' }

      it { is_expected.to be_valid }
    end

    context 'with blank MAAT ID number' do
      let(:maat) { '' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:maat, :blank)).to be(true)
        expect(form.errors.messages[:maat]).to include('Enter the MAAT ID number')
      end
    end

    context 'with invalid format of MAAT ID number' do
      let(:maat) { 'A12345' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:maat, :invalid)).to be(true)
        expect(form.errors.messages[:maat]).to include('The MAAT ID number must be a 7 digit number')
      end
    end
  end

  describe '#save' do
    subject(:save) { form.save }

    let(:application) { create(:prior_authority_application) }

    context 'with valid defendant details' do
      let(:maat) { '1234567' }

      it 'persists the defendant details' do
        expect(application.defendant).to be_nil
        save
        expect(application.defendant).to have_attributes(maat: '1234567')
      end
    end

    context 'with blank MAAT ID number details' do
      let(:maat) { '' }

      it 'does not persists to persist the defendant' do
        expect { save }.not_to change { application.reload.defendant }.from(nil)
      end
    end

    context 'with invalid format of MAAT ID number' do
      let(:maat) { 'A23456' }

      it 'does not persist the defendant' do
        expect { save }.not_to change { application.reload.defendant }.from(nil)
      end
    end

    context 'when defendant already exists' do
      before { defendant }

      let(:defendant) { create(:defendant, :valid_paa, maat: nil, defendable: application) }
      let(:maat) { '1234567' }

      it 'does not add a new defendant' do
        expect { save }.not_to change { application.reload.defendant }.from(defendant)
      end

      it 'updates the existing defendant' do
        expect { save }.to change { application.reload.defendant.maat }.from(nil).to('1234567')
      end
    end
  end
end
