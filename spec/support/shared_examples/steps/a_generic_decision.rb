RSpec.shared_examples 'a generic decision' do |from:, goto:, additional_param: nil|
  subject { described_class.new(form, as: from) }

  context "when step is #{from}" do
    it "moves to #{goto.inspect}" do
      destination = goto
      destination[additional_param] = public_send(additional_param) if additional_param
      expect(subject.destination).to eq(destination)
    end
  end
end
