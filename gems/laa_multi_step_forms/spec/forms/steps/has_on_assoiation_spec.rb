require 'rails_helper'

RSpec.describe Nsm::Steps::HasOneAssociation do
  let(:favourite_meal_form) do
    Class.new(Steps::BaseFormObject) do
      has_one_association :child
      attribute :favourite_meal, :string
    end
  end

  describe '.build' do
    let(:foo_bar_record) do
      Class.new(ApplicationRecord) do
        attr_accessor :favourite_meal, :child

        def build_child
          # This is a placeholder to help with stubbing for tests
        end

        def self.load_schema! = @columns_hash = {}
      end
    end

    before do
      stub_const('FavouriteMealForm', favourite_meal_form)
      stub_const('FooBarRecord', foo_bar_record)
    end

    context 'for an active record argument' do
      let(:child) { FooBarRecord.new(favourite_meal: 'fast') }
      let(:record) { FooBarRecord.new(favourite_meal: 'pizza', child: child) }

      context 'when child exixts' do
        it 'overrides the record to be the child' do
          form = FavouriteMealForm.build(record)

          expect(form.favourite_meal).to eq('fast')
          expect(form.application).to eq(record)
          expect(form.record).to eq(child)
        end
      end

      context 'when the child does not exist' do
        let(:child) { nil }
        let(:new_child) { FooBarRecord.new(favourite_meal: nil) }

        it 'builds a new child' do
          expect(record).to receive(:build_child).and_return(new_child)

          form = FavouriteMealForm.build(record)

          expect(form.favourite_meal).to be_nil
          expect(form.application).to eq(record)
          expect(form.record).to eq(new_child)
        end
      end
    end
  end

  describe 'method on object' do
    subject { form.new(record: nil, application: meal) }

    let(:form) do
      name = associate_name
      Class.new(Steps::BaseFormObject) do
        has_one_association name
      end
    end

    let(:associate) { double(:child) }

    context 'name is not a reseved word' do
      let(:associate_name) { :child }
      let(:meal) { double(:meal, child: associate) }

      it 'defines an accessor on the instance of the object' do
        expect(subject.child).to eq(associate)
      end
    end

    context 'name is a ruby reserved word (like case)' do
      let(:associate_name) { :case }
      let(:meal) { double(:meal, case: associate) }

      it 'prefixes method name with an underscore' do
        expect(subject._case).to eq(associate)
      end
    end
  end
end
