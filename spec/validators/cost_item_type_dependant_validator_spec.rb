require 'rails_helper'

RSpec.describe CostItemTypeDependantValidator do
  subject(:instance) { klass.new(items:, cost_per_item:) }

  let(:klass) do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      def self.model_name
        ActiveModel::Name.new(self, nil, 'temp')
      end

      attribute :items
      attribute :cost_per_item, :gbp

      validates :items, cost_item_type_dependant: { pluralize: true }
      validates :cost_per_item, cost_item_type_dependant: true
    end
  end

  context 'when attribute is a positive number' do
    let(:items) { 1 }
    let(:cost_per_item) { 100 }

    it 'form object is valid' do
      expect(instance).to be_valid
    end
  end

  context 'when attribute is a positive number less than one' do
    let(:items) { 1 }
    let(:cost_per_item) { 0.1 }

    it 'form object is valid' do
      expect(instance).to be_valid
    end
  end

  context 'when attribute is nil' do
    let(:items) { nil }
    let(:cost_per_item) { nil }

    it 'adds blank error' do
      expect(instance).not_to be_valid
      expect(instance.errors.of_kind?(:items, :blank)).to be(true)
      expect(instance.errors.of_kind?(:cost_per_item, :blank)).to be(true)
    end

    it 'adds item_type option to error object' do
      instance.validate
      expect(instance.errors.map(&:options)).to all(include(:item_type))
    end
  end

  context 'when attribute is a string' do
    let(:items) { 'one' }
    let(:cost_per_item) { '100 hundred' }

    it 'adds not_a_number error' do
      expect(instance).not_to be_valid
      expect(instance.errors.of_kind?(:items, :not_a_number)).to be(true)
      expect(instance.errors.of_kind?(:cost_per_item, :not_a_number)).to be(true)
    end
  end

  context 'when attribute is less zero or less' do
    let(:items) { 0 }
    let(:cost_per_item) { 0 }

    it 'adds greater_than error' do
      expect(instance).not_to be_valid
      expect(instance.errors.of_kind?(:items, :greater_than)).to be(true)
      expect(instance.errors.of_kind?(:cost_per_item, :greater_than)).to be(true)
    end
  end

  context 'when model has an cost_item_type attribute' do
    subject(:instance) { klass.new(items:, cost_per_item:, cost_item_type:) }

    let(:klass) do
      Class.new do
        include ActiveModel::Model
        include ActiveModel::Attributes

        def self.model_name
          ActiveModel::Name.new(self, nil, 'temp')
        end

        attribute :cost_item_type, :string

        attribute :items
        attribute :cost_per_item, :gbp

        validates :items, cost_item_type_dependant: { pluralize: true }
        validates :cost_per_item, cost_item_type_dependant: true
      end
    end

    context 'when attribute is nil' do
      let(:items) { nil }
      let(:cost_per_item) { nil }
      let(:cost_item_type) { 'thousand_words' }

      it 'include item type option from model, pluralizing if option set' do
        instance.validate
        expect(instance.errors.details[:items].flat_map(&:values)).to include('1000 words')
        expect(instance.errors.details[:cost_per_item].flat_map(&:values)).to include('1000 words')
      end
    end
  end
end
