require 'rails_helper'

RSpec.describe PriorAuthority::Steps::UfnForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      ufn:,
    }
  end

  describe '#validate' do
    let(:application) { instance_double(PriorAuthorityApplication) }

    context 'with valid format of ufn' do
      let(:ufn) { '230801/001' }

      it { is_expected.to be_valid }
    end

    context 'with blank ufn' do
      let(:ufn) { '' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:ufn, :blank)).to be(true)
        expect(form.errors.messages[:ufn]).to include('Enter the unique file number')
      end
    end

    context 'with ufn in invalid format' do
      let(:ufn) { '111' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:ufn, :invalid)).to be(true)
        expect(form.errors.messages[:ufn]).to include(
          'Unique file number must be in the correct format, for example 310224/001'
        )
      end
    end
  end

  describe '#save' do
    subject(:save) { form.save }

    let(:application) { create(:prior_authority_application, laa_reference: nil) }

    context 'with a valid UFN' do
      let(:ufn) { '230801/001' }

      it 'persists the UFN' do
        expect { save }.to change { application.reload.ufn }.from(nil).to('230801/001')
      end
    end

    context 'with an invalid UFN' do
      let(:ufn) { '11/11' }

      it 'does not persists the UFN' do
        expect { save }.not_to change { application.reload.ufn }.from(nil)
      end
    end

    context 'when laa_reference already exsits' do
      let(:ufn) { '230801/001' }

      before do
        allow(SecureRandom).to receive(:alphanumeric).and_return('AAAAAA', 'BBBBBB')
        allow(PriorAuthorityApplication).to receive(:exists?).with(laa_reference: 'LAA-AAAAAA').and_return(true)
        allow(PriorAuthorityApplication).to receive(:exists?).with(laa_reference: 'LAA-BBBBBB').and_return(false)
      end

      it 'still generates a unique ID' do
        expect { save }.to change { application.reload.laa_reference }.from(nil).to('LAA-BBBBBB')
      end
    end
  end
end
