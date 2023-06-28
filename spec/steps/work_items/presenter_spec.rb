require 'rails_helper'

RSpec.describe Tasks::WorkItems, type: :system do
  subject { described_class.new(application:) }

  let(:application) { Claim.new(attributes) }
  let(:attributes) do
    {
      id: id,
      office_code: 'AAA',
      work_items: work_items,
      navigation_stack: navigation_stack,
    }
  end
  let(:id) { SecureRandom.uuid }
  let(:work_items) { [] }
  let(:navigation_stack) { [] }

  describe '#path' do
    before { allow(application.work_items).to receive(:count).and_return(number_of_work_items) }

    context 'no work_items' do
      before { application.save }

      let(:number_of_work_items) { 0 }

      it { expect(subject.path).to eq("/applications/#{id}/steps/work_item/#{application.reload.work_items.first.id}") }
    end

    context 'one work_item' do
      let(:number_of_work_items) { 1 }

      it { expect(subject.path).to eq("/applications/#{id}/steps/work_items") }
    end

    context 'more than one work_item' do
      let(:number_of_work_items) { 2 }

      it { expect(subject.path).to eq("/applications/#{id}/steps/work_items") }
    end
  end

  describe '#not_applicable?' do
    it { expect(subject).not_to be_not_applicable }
  end

  it_behaves_like 'a task with generic can_start?', Tasks::ClaimDetails

  describe 'in_progress?' do
    context 'navigation_stack include edit work_item path' do
      before { navigation_stack << edit_steps_work_item_path(application, work_item_id: '111') }

      it { expect(subject).to be_in_progress }
    end

    context 'navigation_stack include edit work_items path' do
      before { navigation_stack << edit_steps_work_items_path(application) }

      it { expect(subject).to be_in_progress }
    end

    context 'navigation_stack does not include work_items paths' do
      it { expect(subject).not_to be_in_progress }
    end
  end

  describe '#completed?' do
    context 'when no work items exist' do
      it { expect(subject).not_to be_completed }
    end

    context 'when work items exist' do
      let(:work_items) { [WorkItem.new] }
      let(:work_item_form) { double(:work_item_form, valid?: valid) }

      before do
        allow(Steps::WorkItemForm).to receive(:build).and_return(work_item_form)
      end

      context 'when they are not valid' do
        let(:valid) { false }

        it { expect(subject).not_to be_completed }
      end

      context 'when they are valid' do
        let(:valid) { true }

        it { expect(subject).to be_completed }
      end
    end
  end
end
