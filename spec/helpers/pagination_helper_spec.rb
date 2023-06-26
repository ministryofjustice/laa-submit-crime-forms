require 'rails_helper'

RSpec.describe PaginationHelpers, type: :helper do
  subject { klass.new(params, scope) }
  let(:klass) do
    Class.new do
      include PaginationHelpers
      attr_reader :params, :scope

      def initialize(params, scope)
        @params = params
        @scope = scope
      end

      def data
        scope.page(current_page).per(page_size)
      end
    end
  end
  let(:scope) { double(:recordset) }
  before do
    allow(scope).to receive(:page).and_return(scope)
    allow(scope).to receive(:per).and_return(scope)
  end


  describe '#current_page' do
    context 'when page is set' do
      let(:params) { { page: 3 } }

      it 'it set the page based in the variable' do
        subject.data
        expect(scope).to have_received(:page).with(3)
      end
    end

    context 'when page is not set' do
      let(:params) { { page: nil } }

      it 'it set the page to 1' do
        subject.data
        expect(scope).to have_received(:page).with(1)
      end
    end
  end

  describe '#page_size' do
    context 'when page is set' do
      let(:params) { { limit: 10 } }

      it 'it set the page based in the variable' do
        subject.data
        expect(scope).to have_received(:per).with(10)
      end
    end

    context 'when page is not set' do
      let(:params) { { limit: nil } }

      it 'it set the page to 5' do
        subject.data
        expect(scope).to have_received(:per).with(5)
      end
    end
  end
end