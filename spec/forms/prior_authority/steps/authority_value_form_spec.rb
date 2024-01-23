require 'rails_helper'

RSpec.describe PriorAuthority::Steps::AuthorityValueForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      authority_value:,
    }
  end

  describe '#validate' do
    let(:application) { instance_double(PriorAuthorityApplication) }

    context 'with authority value of true' do
      let(:authority_value) { 'true' }

      it { is_expected.to be_valid }
    end

    context 'with authority value value of false' do
      let(:authority_value) { 'false' }

      it { is_expected.to be_valid }
    end

    context 'with blank authority value value ufn' do
      let(:authority_value) { '' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:authority_value, :inclusion)).to be(true)
        expect(form.errors.messages[:authority_value])
          .to include('Select if you are applying for a total authority of less than £500')
      end
    end
  end

  describe '#save' do
    subject(:save) { form.save }

    let(:application) { create(:prior_authority_application, laa_reference: nil) }

    context 'with authority value value of true' do
      let(:authority_value) { 'true  ' }

      it 'persists the value' do
        expect { save }.to change { application.reload.authority_value }.from(nil).to(true)
      end
    end

    context 'with authority value value of false' do
      let(:authority_value) { 'false' }

      it 'persists the value' do
        expect { save }.to change { application.reload.authority_value }.from(nil).to(false)
      end
    end

    context 'with blank authority value value' do
      let(:authority_value) { '' }

      it 'does not persists the authority value value' do
        expect { save }.not_to change { application.reload.authority_value }.from(nil)
      end
    end
  end
end
