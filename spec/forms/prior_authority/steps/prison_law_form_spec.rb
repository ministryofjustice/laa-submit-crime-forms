require 'rails_helper'

RSpec.describe PriorAuthority::Steps::PrisonLawForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      prison_law:,
    }
  end

  describe '#validate' do
    let(:application) { instance_double(PriorAuthorityApplication) }

    context 'with prison law value of true' do
      let(:prison_law) { 'true' }

      it { is_expected.to be_valid }
    end

    context 'with prison law value of false' do
      let(:prison_law) { 'false' }

      it { is_expected.to be_valid }
    end

    context 'with blank prison law value ufn' do
      let(:prison_law) { '' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:prison_law, :inclusion)).to be(true)
        expect(form.errors.messages[:prison_law]).to include('Select yes if this is a Prison Law matter')
      end
    end
  end

  describe '#save' do
    subject(:save) { form.save }

    let(:application) { create(:prior_authority_application, laa_reference: nil) }

    context 'with prison law value of true' do
      let(:prison_law) { 'true  ' }

      it 'persists the value' do
        expect { save }.to change { application.reload.prison_law }.from(nil).to(true)
      end
    end

    context 'with prison law value of false' do
      let(:prison_law) { 'false' }

      it 'persists the value' do
        expect { save }.to change { application.reload.prison_law }.from(nil).to(false)
      end
    end

    context 'with blank prison law value' do
      let(:prison_law) { '' }

      it 'does not persists the prison law value' do
        expect { save }.not_to change { application.reload.prison_law }.from(nil)
      end
    end
  end
end
