require 'rails_helper'

RSpec.describe Decisions::DslTree do
  subject { decision_tree.new(form, as:) }

  let(:application) { double(:application, id: SecureRandom.uuid) }
  let(:record) { double(:record, id: SecureRandom.uuid) }
  let(:form) { double(:form, application:, record:) }
  let(:wrapper_class) { SimpleDelegator }
  before do
    subject.class.const_set(:WRAPPER_CLASS, wrapper_class)
  end

  describe 'rule without conditions' do
    let(:decision_tree) do
      Class.new(described_class) do
        from(:tree).goto(edit: :branch)
      end
    end

    context 'for known step' do
      let(:as) { :tree }

      it 'matches defined steps' do
        expect(subject.destination).to eq(
          controller: :branch,
          action: :edit,
          id: application
        )
      end
    end

    context 'for unknown step' do
      let(:as) { :other }

      it 'matches defined steps' do
        expect(subject.destination).to eq(
          controller: '/claims',
          action: :index,
        )
      end
    end
  end

  describe 'rule with static additional parameters' do
    let(:decision_tree) do
      Class.new(described_class) do
        from(:tree).goto(edit: :branch, branch_id: 'apple')
      end
    end

    context 'for known step' do
      let(:as) { :tree }

      it 'add the parameters to the url' do
        expect(subject.destination).to eq(
          controller: :branch,
          action: :edit,
          id: application,
          branch_id: 'apple'
        )
      end
    end
  end

  describe 'rule with dynamic additional parameters' do
    let(:decision_tree) do
      Class.new(described_class) do
        from(:tree).goto(edit: :branch, branch_id: -> { application.id })
      end
    end

    context 'for known step' do
      let(:as) { :tree }

      it 'add the parameters to the url' do
        expect(subject.destination).to eq(
          controller: :branch,
          action: :edit,
          id: application,
          branch_id: application.id
        )
      end
    end
  end

  describe 'rule with conditions' do
    let(:application) { double(:application, type:) }
    let(:type) { :apple }
    let(:decision_tree) do
      Class.new(described_class) do
        from(:tree)
          .when(-> { application.type == :apple }).goto(edit: :success)
          .goto(edit: :failure)
      end
    end

    context 'for known step' do
      let(:as) { :tree }

      context 'when condition is true' do
        it 'matches defined steps' do
          expect(subject.destination).to eq(
            controller: :success,
            action: :edit,
            id: application
          )
        end
      end

      context 'when condition is false' do
        let(:type) { :pear }

        it 'matches defined steps' do
          expect(subject.destination).to eq(
            controller: :failure,
            action: :edit,
            id: application
          )
        end
      end
    end

    context 'for unknown step' do
      let(:as) { :other }

      it 'matches defined steps' do
        expect(subject.destination).to eq(
          controller: '/claims',
          action: :index,
        )
      end
    end
  end

  describe 'rule the uses the response from the conditional' do
    let(:as) { :tree }
    let(:decision_tree) do
      Class.new(described_class) do
        from(:tree)
          .when(-> { record }).goto(edit: :success, record_id: ->(inst) { inst.id })
      end
    end

    it 'adds the dynmaic value to the form' do
      expect(subject.destination).to eq(
        controller: :success,
        action: :edit,
        id: application,
        record_id: record.id
      )
    end
  end

  describe 'rule with a custom wrapper class' do
    let(:wrapper_class) do
      Class.new(SimpleDelegator) do
        def wrapper_type
          'Apple'
        end
      end
    end
    let(:as) { :tree }
    let(:decision_tree) do
      Class.new(described_class) do
        from(:tree)
          .when(-> { record }).goto(edit: :success, wrapper_type: -> { wrapper_type })
      end
    end

    it 'adds the dynmaic value to the form' do
      expect(subject.destination).to eq(
        controller: :success,
        action: :edit,
        id: application,
        wrapper_type: 'Apple'
      )
    end
  end
end
