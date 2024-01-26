require 'rails_helper'

RSpec.describe PriorAuthority::Steps::YouthCourtForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      youth_court:,
    }
  end

  describe '#validate' do
    let(:application) { instance_double(PriorAuthorityApplication) }

    context 'with youth court value of true' do
      let(:youth_court) { 'true' }

      it { is_expected.to be_valid }
    end

    context 'with youth court value of fals' do
      let(:youth_court) { 'false' }

      it { is_expected.to be_valid }
    end

    context 'with blank youth court value' do
      let(:youth_court) { '' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:youth_court, :inclusion)).to be(true)
        expect(form.errors.messages[:youth_court]).to include('Select yes if this is a youth court matter')
      end
    end
  end

  describe '#save' do
    subject(:save) { form.save }

    let(:application) { create(:prior_authority_application) }

    context 'with youth court of true' do
      let(:youth_court) { 'true' }

      it 'persists the value' do
        expect { save }.to change { application.reload.youth_court }.from(nil).to(true)
      end
    end

    context 'with youth court of false' do
      let(:youth_court) { 'false' }

      it 'persists the value' do
        expect { save }.to change { application.reload.youth_court }.from(nil).to(false)
      end
    end

    context 'with blank youthcourt value' do
      let(:youth_court) { '' }

      it 'does not persists the authority value value' do
        expect { save }.not_to change { application.reload.youth_court }.from(nil)
      end
    end
  end
end
