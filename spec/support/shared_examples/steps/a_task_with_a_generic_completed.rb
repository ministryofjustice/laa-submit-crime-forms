RSpec.shared_examples 'a task with generic complete?' do |form_class|
  describe '#completed?' do
    let(:form) { instance_double(form_class, valid?: valid) }
    let(:valid) { true }

    before do
      allow(form_class).to receive(:build).and_return(form)
    end

    context 'when valid is true' do
      it { expect(subject).to be_completed }
    end

    context 'when valid is false' do
      let(:valid) { false }

      it { expect(subject).not_to be_completed }
    end
  end
end
