require 'rails_helper'

RSpec.describe Nsm::Steps::ErrorWrapper do
  subject { described_class.new(form, fields) }

  let(:nested_object) { double(:nested_error, errors: double(messages: { nested_field: :error })) }
  let(:form) do
    double(errors_non_nested: double(:error, messages: { field: :error })).tap do |obj|
      allow(obj).to receive(:[]).with(:nested_object).and_return(nested_object)
    end
  end

  context 'fields is nil' do
    let(:fields) { [nil] }

    it 'returns errors.messages from the base object' do
      expect(subject.messages).to eq([[:field, :error]])
    end
  end

  context 'fields is a nested object name' do
    let(:fields) { [:nested_object] }

    it 'returns errors.messages from the nested object with the key mapped to include the object name + attributes' do
      expect(subject.messages).to eq([['nested_object_attributes_nested_field', :error]])
    end
  end

  context 'fielss is nil and nested object name' do
    let(:fields) { [nil, :nested_object] }

    it 'returns the combined errors.messages mapped responsed from the base and nested object' do
      expect(subject.messages).to eq([[:field, :error], ['nested_object_attributes_nested_field', :error]])
    end
  end
end
