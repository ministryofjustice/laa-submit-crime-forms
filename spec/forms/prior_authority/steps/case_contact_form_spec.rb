require 'rails_helper'

RSpec.describe PriorAuthority::Steps::CaseContactForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      firm_office_attributes:,
      solicitor_attributes:,
    }
  end

  let(:firm_office_attributes) { nil }
  let(:solicitor_attributes) { nil }

  describe '#validate' do
    let(:application) { instance_double(PriorAuthorityApplication) }

    context 'with valid solicitor and firm details' do
      let(:firm_office_attributes) { { 'name' => 'anything', 'account_number' => 'anything' } }
      let(:solicitor_attributes) do
        { 'contact_first_name' => 'Joe', 'contact_last_name' => 'Bloggs', 'contact_email' => 'joe.bloggs@legalcorp.com' }
      end

      it { is_expected.to be_valid }
    end

    context 'with invalid solicitor and firm details' do
      let(:firm_office_attributes) { { 'name' => '', 'account_number' => '' } }
      let(:solicitor_attributes) { { 'contact_first_name' => '', 'contact_last_name' => '', 'contact_email' => '' } }

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:'firm_office-attributes.name', :blank)).to be(true)
        expect(form.errors.of_kind?(:'firm_office-attributes.account_number', :blank)).to be(true)
        expect(form.errors.of_kind?(:'solicitor-attributes.contact_first_name', :blank)).to be(true)
        expect(form.errors.of_kind?(:'solicitor-attributes.contact_last_name', :blank)).to be(true)
        expect(form.errors.of_kind?(:'solicitor-attributes.contact_email', :blank)).to be(true)
        expect(form.errors.messages.values.flatten).to include('Enter a firm name',
                                                               'Enter an account number',
                                                               'Enter the first name of the contact',
                                                               'Enter the last name of the contact',
                                                               'Enter the email address of the contact')
      end
    end
  end

  describe '#save' do
    subject(:save) { form.save }

    let(:application) { create(:prior_authority_application) }

    context 'with valid solicitor and firm details' do
      let(:firm_office_attributes) { { 'name' => 'anything', 'account_number' => 'anything' } }
      let(:solicitor_attributes) do
        { 'contact_first_name' => 'Joe', 'contact_last_name' => 'Bloggs', 'contact_email' => 'joe.bloggs@legalcorp.com' }
      end

      it 'persists the firm details' do
        expect { save }.to change { application.reload.firm_office }.from(nil).to(be_a(FirmOffice))
        expect(application.firm_office).to have_attributes(name: 'anything', account_number: 'anything')
      end

      it 'persists the solicitor details' do
        expect { save }.to change { application.reload.solicitor }.from(nil).to(be_a(Solicitor))
        expect(application.solicitor).to have_attributes(contact_first_name: 'Joe',
                                                         contact_last_name: 'Bloggs',
                                                         contact_email: 'joe.bloggs@legalcorp.com')
      end
    end

    context 'with invalid solicitor and firm details' do
      let(:firm_office_attributes) { { 'name' => '', 'account_number' => '' } }
      let(:solicitor_attributes) { { 'contact_first_name' => '', 'contact_last_name' => '', 'contact_email' => '' } }

      it 'does not persists the solicitor details' do
        expect { save }.not_to change { application.reload.solicitor }.from(nil)
      end

      it 'does not persists the firm details' do
        expect { save }.not_to change { application.reload.firm_office }.from(nil)
      end
    end
  end
end
