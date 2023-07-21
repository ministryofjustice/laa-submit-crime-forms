RSpec.shared_examples 'a generic decision' do |from:, goto:, additional_param: nil|
  subject { described_class.new(form, as: from) }

  context "when step is #{from}" do
    it "moves to #{goto.inspect}" do
      destination = goto
      destination[additional_param] = public_send(additional_param) if additional_param
      destination[:id] = application unless destination[:action] == :index

      expect(subject.destination).to eq(destination)
    end
  end
end

RSpec.shared_examples 'an add_another decision' do |step_name, yes_controller_name, no_controller,
  id_field, action_name: :edit, no_action_name: :edit, additional_yes_branch_tests: nil|
  let(:form) { Steps::AddAnotherForm.new(application:, add_another:) }
  let(:decision_tree) { described_class.new(form, as: step_name) }
  let(:add_another) { 'yes' }

  context "when step is #{step_name}" do
    context 'when add_another is YES' do
      it "moves to #{yes_controller_name}##{action_name}" do
        expect(decision_tree.destination).to match(
          :action => action_name,
          :controller => yes_controller_name,
          :id => application,
          id_field => an_instance_of(String),
        )
      end

      # This allow passing in of additional checks for 'yes' branch that are then executed in this scope.
      context 'additional tests', &additional_yes_branch_tests if additional_yes_branch_tests
    end

    context 'when add_another is NO' do
      let(:add_another) { 'no' }

      if no_controller.is_a?(Symbol)
        it "moves to #{no_controller}##{no_action_name}" do
          expect(decision_tree.destination).to eq(
            action: no_action_name,
            controller: no_controller,
            id: application,
          )
        end
      else
        let(:routing) { instance_eval(&no_controller[:routing]) }

        it "moves to #{no_controller[:name]}##{action_name}" do
          expect(decision_tree.destination).to eq(
            routing.merge(
              action: no_action_name,
              id: application,
            )
          )
        end
      end
    end
  end
end
