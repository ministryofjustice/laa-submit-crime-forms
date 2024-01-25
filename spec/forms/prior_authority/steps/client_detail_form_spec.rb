require 'rails_helper'

RSpec.describe PriorAuthority::Steps::ClientDetailForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      record:,
      first_name:,
      last_name:,
      date_of_birth:,
    }
  end

  describe '#validate' do
    let(:record) { instance_double(Defendant) }

    context 'with valid client details' do
      let(:first_name) { 'Joe' }
      let(:last_name) { 'Bloggs' }
      let(:date_of_birth) { 20.years.ago.to_date }

      it { is_expected.to be_valid }
    end

    context 'with blank client details' do
      let(:first_name) { '' }
      let(:last_name) { '' }
      let(:date_of_birth) { '' }

      it 'has a validation errors on the fields' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:first_name, :blank)).to be(true)
        expect(form.errors.of_kind?(:last_name, :blank)).to be(true)
        expect(form.errors.of_kind?(:date_of_birth, :blank)).to be(true)
        expect(form.errors.messages.values.flatten)
          .to include("Enter the client's first name",
                      "Enter the client's last name",
                      "Enter the client's date of birth")
      end
    end
  end

  describe '#save' do
    subject(:save) { form.save }

    let(:record) { create(:defendant, defendable: create(:prior_authority_application)) }

    context 'with valid client details' do
      let(:first_name) { 'Joe' }
      let(:last_name) { 'Bloggs' }
      let(:date_of_birth) { 20.years.ago.to_date }

      it 'persists the client details' do
        expect { save }.to change { record.reload.attributes }
          .from(
            hash_including(
              'first_name' => nil,
              'last_name' => nil,
              'date_of_birth' => nil
            )
          )
          .to(
            hash_including(
              'first_name' => 'Joe',
              'last_name' => 'Bloggs',
              'date_of_birth' => 20.years.ago.to_date
            )
          )
      end
    end

    context 'with incomplete client details' do
      let(:first_name) { 'Joe' }
      let(:last_name) { '' }
      let(:date_of_birth) { '' }

      it 'does not persist the client details' do
        expect { save }.not_to change { record.reload.attributes }
          .from(
            hash_including(
              'first_name' => nil,
              'last_name' => nil,
              'date_of_birth' => nil
            )
          )
      end
    end
  end
end
