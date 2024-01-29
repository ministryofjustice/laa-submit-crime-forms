require 'rails_helper'

RSpec.describe PriorAuthority::Steps::CaseContact::FirmDetailForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      name:,
      account_number:,
    }
  end

  describe '#validate' do
    let(:application) { instance_double(PriorAuthorityApplication) }

    context 'with valid name and account number' do
      let(:name) { 'anything' }
      let(:account_number) { 'anything' }

      it { is_expected.to be_valid }
    end

    context 'with blank name' do
      let(:name) { '' }
      let(:account_number) { 'anything' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:name, :blank)).to be(true)
        expect(form.errors.messages[:name]).to include('Enter a firm name')
      end
    end

    context 'with blank account numberr' do
      let(:name) { 'anything' }
      let(:account_number) { '' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:account_number, :blank)).to be(true)
        expect(form.errors.messages[:account_number]).to include('Enter an account number')
      end
    end
  end

  describe '#save' do
    subject(:save) { form.save }

    let(:application) { create(:prior_authority_application) }

    context 'with valid firm details' do
      let(:name) { 'anything' }
      let(:account_number) { 'anything' }

      it 'persists the firm details' do
        expect(application.firm_office).to be_nil
        save
        expect(application.firm_office).to have_attributes(name: 'anything', account_number: 'anything')
      end
    end

    context 'with invalid firm details' do
      let(:name) { '' }
      let(:account_number) { '' }

      it 'does not persists firm details' do
        expect { save }.not_to change { application.reload.firm_office }.from(nil)
      end
    end
  end
end
