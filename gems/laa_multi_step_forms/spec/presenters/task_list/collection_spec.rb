require 'rails_helper'

RSpec.describe TaskList::Collection do
  include ActionView::TestCase::Behavior

  subject { klass.new(view, application:) }

  let(:klass) do
    Class.new(described_class).tap do |klass|
      klass.const_set(:SECTIONS, [[:a, [:a1, :a2]], [:b, [:b1]]])
    end
  end
  let(:name) { :foobar_task }
  let(:application) { double }

  describe 'collection of sections' do
    it 'returns the section details' do
      expect(subject[0].index).to eq(1)
      expect(subject[0].name).to eq(:a)
      expect(subject[0].tasks).to eq([:a1, :a2])

      expect(subject[1].index).to eq(2)
      expect(subject[1].name).to eq(:b)
      expect(subject[1].tasks).to eq([:b1])
    end

    context 'when SECTIONS is not defined' do
      let(:klass) { Class.new(described_class) }

      it 'raises an error' do
        expect { subject[0] }.to raise_error('implement SECTIONS, in subclasses')
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
      expect(subject.completed).to eq([task_completed])
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
        subject.render
      ).to match(%r{<ol class="moj-task-list">.*</ol>})
    end
  end
end
