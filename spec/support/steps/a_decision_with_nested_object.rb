RSpec.shared_examples 'a decision with nested object' do |step_name:, controller:, summary_controller:,
    form_class:, nested: controller, edit_when_one: false, create_args: nil|
  context "when step is #{step_name}" do
    let(:local_form) { form_class.new(application:) }
    let(:decision_tree) { described_class.new(local_form, as: step_name) }
    let(:nested_instance) { double(nested, id: SecureRandom.uuid) }

    context "when no #{nested}s exist" do
      let(:nested_scope) { application.public_send("#{nested}s") }

      it 'moves to the page for the disbursement' do
        expect(decision_tree.destination).to eq(
          action: :edit,
          controller: controller,
          id: application,
          "#{nested}_id": StartPage::CREATE_FIRST,
        )
      end
    end

    context "when one #{nested} exists" do
      before do
        allow(application).to receive("#{nested}s").and_return([nested_instance])
      end

      if edit_when_one
        it "moves to page for the first #{nested}" do
          expect(decision_tree.destination).to eq(
            action: :edit,
            controller: controller,
            id: application,
            "#{nested}_id": nested_instance.id,
          )
        end
      else
        it "moves to page for the #{nested} summary page" do
          expect(decision_tree.destination).to eq(
            action: :edit,
            controller: summary_controller,
            id: application,
          )
        end
      end
    end

    context "when multiple #{nested}s exists" do
      before do
        allow(application).to receive("#{nested}s").and_return([nested_instance, nested_instance])
      end

      it "moves to page for the #{nested} summary page" do
        expect(decision_tree.destination).to eq(
          action: :edit,
          controller: summary_controller,
          id: application,
        )
      end
    end
  end
end
