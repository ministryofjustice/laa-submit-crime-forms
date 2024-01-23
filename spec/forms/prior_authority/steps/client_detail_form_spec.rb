require 'rails_helper'

RSpec.describe PriorAuthority::Steps::ClientDetailForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      client_first_name:,
      client_last_name:,
      client_date_of_birth:,
    }
  end

  describe '#validate' do
    let(:application) { instance_double(PriorAuthorityApplication) }

    context 'with valid client details' do
      let(:client_first_name) { 'Joe' }
      let(:client_last_name) { 'Bloggs' }
      let(:client_date_of_birth) { 20.years.ago.to_date }

      it { is_expected.to be_valid }
    end

    context 'with blank client details' do
      let(:client_first_name) { '' }
      let(:client_last_name) { '' }
      let(:client_date_of_birth) { '' }

      it 'has a validation errors on the fields' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:client_first_name, :blank)).to be(true)
        expect(form.errors.of_kind?(:client_last_name, :blank)).to be(true)
        expect(form.errors.of_kind?(:client_date_of_birth, :blank)).to be(true)
        expect(form.errors.messages.values.flatten)
          .to include("Enter the client's first name",
                      "Enter the client's last name",
                      "Enter the client's date of birth")
      end
    end
  end

  describe '#save' do
    subject(:save) { form.save }

    let(:application) { create(:prior_authority_application) }

    context 'with valid client details' do
      let(:client_first_name) { 'Joe' }
      let(:client_last_name) { 'Bloggs' }
      let(:client_date_of_birth) { 20.years.ago.to_date }

      it 'persists the client details' do
        expect { save }.to change { application.reload.attributes }
          .from(
            hash_including(
              'client_first_name' => nil,
              'client_last_name' => nil,
              'client_date_of_birth' => nil
            )
          )
          .to(
            hash_including(
              'client_first_name' => 'Joe',
              'client_last_name' => 'Bloggs',
              'client_date_of_birth' => 20.years.ago.to_date
            )
          )
      end
    end

    context 'with incomplete client details' do
      let(:client_first_name) { 'Joe' }
      let(:client_last_name) { '' }
      let(:client_date_of_birth) { '' }

      it 'does not persist the client details' do
        expect { save }.not_to change { application.reload.attributes }
          .from(
            hash_including(
              'client_first_name' => nil,
              'client_last_name' => nil,
              'client_date_of_birth' => nil
            )
          )
      end
    end
  end
end
