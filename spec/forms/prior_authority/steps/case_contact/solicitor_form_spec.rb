require 'rails_helper'

RSpec.describe PriorAuthority::Steps::CaseContact::SolicitorForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      contact_full_name:,
      contact_email:,
    }
  end

  describe '#validate' do
    let(:application) { instance_double(PriorAuthorityApplication) }

    context 'with valid name and account number' do
      let(:contact_full_name) { 'Joe Bloggs' }
      let(:contact_email) { 'joe.bloggs@legalcorp.com' }

      it { is_expected.to be_valid }
    end

    context 'with blank contact_full_name' do
      let(:contact_full_name) { '' }
      let(:contact_email) { 'joe.bloggs@legalcorp.com' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:contact_full_name, :blank)).to be(true)
        expect(form.errors.messages[:contact_full_name]).to include('Enter the full name of the contact')
      end
    end

    context 'with an invalid contact_full_name' do
      let(:contact_full_name) { 'Joe' }
      let(:contact_email) { 'joe.bloggs@legalcorp.com' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:contact_full_name, :invalid)).to be(true)
        expect(form.errors.messages[:contact_full_name])
          .to include(match("Contact's name must only include letters a to z"))
      end
    end

    context 'with blank contact_email' do
      let(:contact_full_name) { 'Joe Bloggs' }
      let(:contact_email) { '' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:contact_email, :blank)).to be(true)
        expect(form.errors.messages[:contact_email]).to include('Enter the email address of the contact')
      end
    end

    context 'with an invalid contact_email' do
      let(:contact_full_name) { 'Joe' }
      let(:contact_email) { 'joe.bloggsatlegalcorp.com' }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:contact_email, :invalid)).to be(true)
        expect(form.errors.messages[:contact_email]).to include('Enter a valid email address')
      end
    end
  end

  describe '#save' do
    subject(:save) { form.save }

    let(:application) { create(:prior_authority_application) }

    context 'with valid solicitor details' do
      let(:contact_full_name) { 'Joe Bloggs' }
      let(:contact_email) { 'joe.bloggs@legalcorp.com' }

      it 'persists the solicitor details' do
        expect(application.solicitor).to be_nil
        save
        expect(application.solicitor).to have_attributes(contact_full_name: 'Joe Bloggs',
                                                         contact_email: 'joe.bloggs@legalcorp.com')
      end
    end

    context 'with invalid solicitor details' do
      let(:contact_full_name) { '' }
      let(:contact_email) { '' }

      it 'does not persists to persist the solicitor' do
        expect { save }.not_to change { application.reload.solicitor }.from(nil)
      end
    end
  end
end
