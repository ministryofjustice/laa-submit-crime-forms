require 'rails_helper'

RSpec.describe Nsm::CheckAnswers::Base do
  describe '#row_data' do
    it 'generates empty placeholder array' do
      expect(subject.row_data).to eq(
        []
      )
    end
  end
end
