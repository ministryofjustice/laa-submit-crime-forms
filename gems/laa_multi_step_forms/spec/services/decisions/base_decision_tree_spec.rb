require 'rails_helper'

RSpec.describe Decisions::BaseDecisionTree do
  subject { described_class.new(form, as: location) }

  let(:form) { double(:form, application:) }
  let(:location) { :start_page }
  let(:application) { double(:application) }

  describe '#destination' do
    it 'raises an error' do
      expect { subject.destination }.to raise_error('implement this action, in subclasses')
    end
  end

  describe '#current_application' do
    it 'returns the forms application' do
      expect(subject.current_application).to eq(application)
    end
  end
end
