require 'rails_helper'

RSpec.describe PriorAuthority::Steps::PrimaryQuoteForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      record:,
      service_name:,
      contact_full_name:,
      organisation:,
      postcode:,
    }
  end

  describe '#validate' do
    let(:record) { instance_double(Quote) }

    context 'with valid quote details' do
      let(:service_name) { 'Forensics Expert' }
      let(:contact_full_name) { 'Joe Bloggs' }
      let(:organisation) { 'LAA' }
      let(:postcode) { 'CR0 1RE' }

      it { is_expected.to be_valid }
    end

    context 'with blank quote details' do
      let(:service_name) { '' }
      let(:contact_full_name) { '' }
      let(:organisation) { '' }
      let(:postcode) { '' }

      it 'has a validation errors on blank fields' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:service_name, :blank)).to be(true)
        expect(form.errors.of_kind?(:contact_full_name, :blank)).to be(true)
        expect(form.errors.of_kind?(:organisation, :blank)).to be(true)
        expect(form.errors.of_kind?(:postcode, :blank)).to be(true)
        expect(form.errors.messages.values.flatten)
          .to include("Enter the service required",
                      "Enter the contact's full name",
                      "Enter the organisation name",
                      "Enter the postcode")
      end
    end

    context 'with invalid quote details' do
      let(:service_name) { 'Forensics Expert' }
      let(:contact_full_name) { 'Tim' }
      let(:organisation) { 'LAA' }
      let(:postcode) { 'loren ipsum' }

      it 'has a validation errors on blank fields' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:contact_full_name, :invalid)).to be(true)
        expect(form.errors.of_kind?(:postcode, :invalid)).to be(true)
        expect(form.errors.messages.values.flatten)
          .to include("Enter a valid full name",
                      "Enter a real postcode")
      end
    end
  end

  describe '#save' do
    subject(:save) { form.save }

    let(:record) { create(:quote) }

    context 'with valid quote details' do
      let(:service_name) { 'Forensics Expert' }
      let(:contact_full_name) { 'Joe Bloggs' }
      let(:organisation) { 'LAA' }
      let(:postcode) { 'CR0 1RE' }

      it 'persists the quote' do
        expect { save }.to change { record.reload.attributes }
          .from(
            hash_including(
              'service_name' => nil,
              'contact_full_name' => nil,
              'organisation' => nil,
              'postcode' => nil,
              'primary' => nil
            )
          )
          .to(
            hash_including(
              'service_name' => 'Forensics Expert',
              'contact_full_name' => 'Joe Bloggs',
              'organisation' => 'LAA',
              'postcode' => 'CR0 1RE',
              'primary' => true
            )
          )
      end
    end

    context 'with incomplete quote details' do
      let(:service_name) { 'Forensics Expert' }
      let(:contact_full_name) { '' }
      let(:organisation) { '' }
      let(:postcode) { '' }

      it 'does not persist the client details' do
        expect { save }.not_to change { record.reload.attributes }
          .from(
            hash_including(
              'service_name' => nil,
              'contact_full_name' => nil,
              'organisation' => nil,
              'postcode' => nil,
              'primary' => nil
            )
          )
      end
    end
  end
end
