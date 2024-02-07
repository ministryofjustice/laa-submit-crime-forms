require 'rails_helper'

RSpec.describe PriorAuthority::Steps::PrimaryQuoteForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      record:,
      service_type:,
      contact_full_name:,
      organisation:,
      postcode:,
    }
  end

  let(:record) { instance_double(Quote) }
  let(:service_type) { 'Forensics Expert' }
  let(:contact_full_name) { 'Joe Bloggs' }
  let(:organisation) { 'LAA' }
  let(:postcode) { 'CR0 1RE' }

  describe '#validate' do
    context 'with valid quote details' do
      it { is_expected.to be_valid }
    end

    context 'with blank quote details' do
      let(:service_type) { '' }
      let(:contact_full_name) { '' }
      let(:organisation) { '' }
      let(:postcode) { '' }

      it 'has a validation errors on blank fields' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:service_type, :blank)).to be(true)
        expect(form.errors.of_kind?(:contact_full_name, :blank)).to be(true)
        expect(form.errors.of_kind?(:organisation, :blank)).to be(true)
        expect(form.errors.of_kind?(:postcode, :blank)).to be(true)
        expect(form.errors.messages.values.flatten)
          .to include('Enter the service required',
                      "Enter the contact's full name",
                      'Enter the organisation name',
                      'Enter the postcode')
      end
    end

    context 'with invalid quote details' do
      let(:service_type) { 'Forensics Expert' }
      let(:contact_full_name) { 'Tim' }
      let(:organisation) { 'LAA' }
      let(:postcode) { 'loren ipsum' }

      it 'has a validation errors on blank fields' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:contact_full_name, :invalid)).to be(true)
        expect(form.errors.of_kind?(:postcode, :invalid)).to be(true)
        expect(form.errors.messages.values.flatten)
          .to include('Enter a valid full name',
                      'Enter a real postcode')
      end
    end
  end

  describe '#save' do
    subject(:save) { form.save }

    let(:record) { create(:quote, :blank, prior_authority_application: create(:prior_authority_application)) }

    context 'with valid quote details' do
      let(:service_type) { 'Forensics Expert' }
      let(:contact_full_name) { 'Joe Bloggs' }
      let(:organisation) { 'LAA' }
      let(:postcode) { 'CR0 1RE' }

      it 'persists the quote' do
        expect { save }.to change { record.reload.attributes }
          .from(
            hash_including(
              'service_type' => nil,
              'contact_full_name' => nil,
              'organisation' => nil,
              'postcode' => nil,
              'primary' => nil
            )
          )
          .to(
            hash_including(
              'service_type' => 'Forensics Expert',
              'custom_service_name' => nil,
              'contact_full_name' => 'Joe Bloggs',
              'organisation' => 'LAA',
              'postcode' => 'CR0 1RE',
              'primary' => true
            )
          )
      end
    end

    context 'with incomplete quote details' do
      let(:service_type) { 'Forensics Expert' }
      let(:contact_full_name) { '' }
      let(:organisation) { '' }
      let(:postcode) { '' }

      it 'does not persist the client details' do
        expect { save }.not_to change { record.reload.attributes }
          .from(
            hash_including(
              'service_type' => nil,
              'contact_full_name' => nil,
              'organisation' => nil,
              'postcode' => nil,
              'primary' => nil
            )
          )
      end
    end
  end

  describe '#service_type' do
    subject(:form) { described_class.new(arguments.merge(service_type_suggestion:)) }

    let(:service_type) { 'culture_expert' }

    context 'service type suggestion matches provided service' do
      let(:service_type_suggestion) { 'Culture expert' }

      it { expect(subject.service_type).to eq(PriorAuthority::QuoteServices::CULTURE_EXPERT) }
    end

    context 'service type suggestion matches a different service' do
      let(:service_type_suggestion) { 'Computer Experts' }

      it 'uses the service type associated with the suggestion' do
        expect(subject.service_type).to eq(PriorAuthority::QuoteServices::COMPUTER_EXPERTS)
      end
    end

    context 'service type suggestion does not match a quote service' do
      let(:service_type_suggestion) { 'garbage value' }

      it { expect(subject.service_type).to eq(PriorAuthority::QuoteServices.new('custom')) }
    end
  end

  describe '#custom_service_name' do
    subject(:form) { described_class.new(arguments.merge(service_type_suggestion:)) }

    let(:service_type) { PriorAuthority::QuoteServices.values.sample }

    context 'service type suggestion matches a quote service' do
      let(:service_type_suggestion) { service_type.translated }

      it { expect(subject.custom_service_name).to be_nil }
    end

    context 'service type suggestion does not match a quote service' do
      let(:service_type_suggestion) { 'garbage value' }

      it { expect(subject.custom_service_name).to eq('garbage value') }
    end
  end
end
