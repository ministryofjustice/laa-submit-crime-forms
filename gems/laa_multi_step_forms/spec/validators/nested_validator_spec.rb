require 'rails_helper'

RSpec.describe NestedValidator do
  subject { klass.new(name: 'parent', nested_object:, named_nested_object:) }

  let(:klass) do
    Class.new(Steps::BaseFormObject) do
      attr_accessor :name, :nested_object, :named_nested_object

      validates :name, presence: true
      validates :nested_object, nested: true
      validates :named_nested_object, nested: { name: :namer }

      def self.model_name
        Struct.new(:i18n_key, :human).new('nested_validator_object', 'nested object')
      end

      def namer(index)
        'child'
      end
    end
  end
  let(:named_nested_object) { nil }

  context 'when nested object is an array' do
    context 'when array is nil' do
      let(:nested_object) { nil }

      it { expect(subject).to be_valid }
    end

    context 'when array is empty' do
      let(:nested_object) { [] }

      it { expect(subject).to be_valid }
    end

    context 'when objects are valid' do
      let(:nested_object) { [klass.new(name: 'child1')] }

      it { expect(subject).to be_valid }
    end

    context 'when an object is invalid' do
      let(:nested_object) { [klass.new(name: nil)] }

      it 'add validation errors to the parent' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?('nested_object-attributes[0].name', :blank)).to be(true)
      end

      it 'defines a method to access the attribute' do
        expect(subject).not_to be_valid
        expect(subject).to respond_to('nested_object-attributes[0].name')
        expect(subject.method('nested_object-attributes[0].name').call).to eq(nil)
      end

      context 'translations' do
        around do |spec|
          I18n.backend.load_translations unless I18n.backend.initialized?

          summary = { name: { blank: 'Nested object %{name} is not valid' } }
          data = { activemodel: { errors: { models: { nested_validator_object: { summary: } } } } }
          I18n.backend.store_translations(:en, data)

          spec.run
          I18n.backend.reload!
        end

        it 'puts the index into the message' do
          expect(subject).not_to be_valid
          expect(subject.errors['nested_object-attributes[0].name']).to eq(['Nested object 1 is not valid'])
        end

        context 'when a name option is passed in' do
          let(:nested_object) { nil }
          let(:named_nested_object) { [klass.new(name: nil)] }

          it 'puts the response of the name method into the message' do
            expect(subject).not_to be_valid
            expect(subject.errors['named_nested_object-attributes[0].name']).to eq(['Nested object child is not valid'])
          end
        end
      end
    end

    context 'when multiple objects are invalid' do
      let(:nested_object) { [klass.new(name: nil), klass.new(name: 'valid'), klass.new(name: nil)] }

      it 'add validation errors to the parent' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?('nested_object-attributes[0].name', :blank)).to be(true)
        expect(subject.errors.of_kind?('nested_object-attributes[1].name', :blank)).to be(false)
        expect(subject.errors.of_kind?('nested_object-attributes[2].name', :blank)).to be(true)
      end
    end
  end

  context 'when nested object is an instance' do
    context 'when object is nil' do
      let(:nested_object) { nil }

      it { expect(subject).to be_valid }
    end

    context 'when object is valid' do
      let(:nested_object) { klass.new(name: 'child1') }

      it { expect(subject).to be_valid }
    end

    context 'when an object is invalid' do
      let(:nested_object) { klass.new(name: nil) }

      it 'add validation errors to the parent' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?('nested_object-attributes.name', :blank)).to be(true)
      end

      it 'defines a method to access the attribute' do
        expect(subject).not_to be_valid
        expect(subject).to respond_to('nested_object-attributes.name')
        expect(subject.method('nested_object-attributes.name').call).to eq(nil)
      end

      context 'translations' do
        around do |spec|
          I18n.backend.load_translations unless I18n.backend.initialized?

          summary = { name: { blank: 'Nested object %{name} is not valid' } }
          data = { activemodel: { errors: { models: { nested_validator_object: { summary: } } } } }
          I18n.backend.store_translations(:en, data)

          spec.run
          I18n.backend.reload!
        end

        it 'puts the index into the message' do
          expect(subject).not_to be_valid
          expect(subject.errors['nested_object-attributes.name']).to eq(['Nested object 1 is not valid'])
        end

        context 'when a name option is passed in' do
          let(:nested_object) { nil }
          let(:named_nested_object) { klass.new(name: nil) }

          it 'puts the response of the name method into the message' do
            expect(subject).not_to be_valid
            expect(subject.errors['named_nested_object-attributes.name']).to eq(['Nested object child is not valid'])
          end
        end
      end
    end
  end
end
