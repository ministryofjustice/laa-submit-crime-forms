require 'rails_helper'

RSpec.describe TaskList::Collection do
  include ActionView::TestCase::Behavior

  subject(:collection) { klass.new(view, application:, show_index:) }

  let(:klass) do
    Class.new(described_class).tap do |klass|
      klass.const_set(:SECTIONS, [[:a, [:a1, :a2]], [:b, [:b1]]])
    end
  end
  let(:name) { :foobar_task }
  let(:application) { double }
  let(:show_index) { true }

  describe 'collection of sections' do
    it 'returns the section details' do
      expect(collection[0].index).to eq(1)
      expect(collection[0].name).to eq(:a)
      expect(collection[0].tasks).to eq([:a1, :a2])

      expect(collection[1].index).to eq(2)
      expect(collection[1].name).to eq(:b)
      expect(collection[1].tasks).to eq([:b1])
    end

    context 'when SECTIONS is not defined' do
      let(:klass) { Class.new(described_class) }

      it 'raises an error' do
        expect { collection[0] }.to raise_error('implement SECTIONS, in subclasses')
      end
    end
  end

  describe '#completed' do
    before do
      allow(TaskList::Task).to receive(:new).and_return(task_completed, task_incomplete)
    end

    let(:task_completed) { double(completed?: true) }
    let(:task_incomplete) { double(completed?: false) }

    it 'returns only the completed tasks' do
      expect(collection.completed).to eq([task_completed])
    end
  end

  describe '#render' do
    before do
      # We test the Section separately, here we don't need to
      allow_any_instance_of(TaskList::Section).to receive(:render).and_return('[section_markup]')
    end

    it 'iterates through the sections defined, rendering each one' do
      expect(
        TaskList::Section
      ).to receive(:new).twice.and_return(double.as_null_object)

      expect(
        collection.render
      ).to match(%r{<ol class="moj-task-list">.*</ol>})
    end

    context 'when show_index is false' do
      let(:show_index) { false }

      it 'creates Sections with index set to nil' do
        expect(TaskList::Section).to receive(:new).twice do |_application, **keys|
          expect(keys).to include(index: nil)
        end
        collection
      end
    end
  end
end
