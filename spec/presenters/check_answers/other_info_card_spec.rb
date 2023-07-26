require 'rails_helper'

RSpec.describe CheckAnswers::OtherInfoCard do
  subject { described_class.new(claim) }

  let(:claim) { instance_double(Claim) }
  let(:form) do
    instance_double(Steps::OtherInfoForm, other_info:)
  end
  let(:other_info) { 'Line 1' }

  before do
    allow(Steps::OtherInfoForm).to receive(:build).and_return(form)
  end

  describe '#initialize' do
    it 'creates the data instance' do
      subject
      expect(Steps::OtherInfoForm).to have_received(:build).with(claim)
    end
  end

  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Other relevant information')
    end
  end

  describe '#row_data' do
    context '1 line of information' do
      it 'generates a row with one line of relevant information' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'other_info',
              text: 'Line 1'
            }
          ]
        )
      end
    end

    context 'generates a row with 2 lines of relevant information' do
      let(:other_info) { "Line 1\nLine 2" }

      it 'generates case detail rows with 1 line of address' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'other_info',
              text: 'Line 1<br>Line 2'
            }
          ]
        )
      end
    end
  end
end