require 'rails_helper'

RSpec.describe Nsm::IncompleteItems do
  subject { described_class.new(claim, type, controller) }

  let(:claim) { create(:claim) }
  let(:type) { nil }
  let(:controller) { ApplicationController.new }

  # context 'when the item type is work items' do

  # end

  # context 'when the item type is disbursements' do

  # end

  context 'when the item type is unprocessable' do
    let(:type) { 'garbage' }

    it 'raises error on initialization' do
      expect { subject }.to raise_error('Invalid item type: garbage')
    end
  end
end
