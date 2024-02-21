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

    context 'with valid MAAT number' do
      let(:maat) { '123456' }

      it { is_expected.to be_valid }
    end

    context 'with blank MAAT number' do
      let(:maat) { '' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:maat, :blank)).to be(true)
        expect(form.errors.messages[:maat]).to include('Enter the MAAT number')
      end
    end

    context 'with invalid format of MAAT number' do
      let(:maat) { 'A12345' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:maat, :invalid)).to be(true)
        expect(form.errors.messages[:maat]).to include('The MAAT number must only contain numbers')
      end
    end
  end

  describe '#save' do
    subject(:save) { form.save }

    let(:application) { create(:prior_authority_application) }

    context 'with valid defendant details' do
      let(:maat) { '123456' }

      it 'persists the defendant details' do
        expect(application.defendant).to be_nil
        save
        expect(application.defendant).to have_attributes(maat: '123456')
      end
    end

    context 'with blank MAAT number details' do
      let(:maat) { '' }

      it 'does not persists to persist the defendant' do
        expect { save }.not_to change { application.reload.defendant }.from(nil)
      end
    end

    context 'with invalid format of MAAT number' do
      let(:maat) { 'A23456' }

      it 'does not persist the defendant' do
        expect { save }.not_to change { application.reload.defendant }.from(nil)
      end
    end

    context 'when defendant already exists' do
      before { defendant }

      let(:defendant) { create(:defendant, :valid_paa, maat: nil, defendable: application) }
      let(:maat) { '123456' }

      it 'does not add a new defendant' do
        expect { save }.not_to change { application.reload.defendant }.from(defendant)
      end

      it 'updates the existing defendant' do
        expect { save }.to change { application.reload.defendant.maat }.from(nil).to('123456')
      end
    end
  end
end
