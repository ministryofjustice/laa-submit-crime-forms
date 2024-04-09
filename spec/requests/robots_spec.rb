require 'rails_helper'

RSpec.describe 'Robots' do
  context 'when indexing is disallowed' do
    it 'makes this clear' do
      get '/robots.txt'
      expect(response.body.chomp).to eq "User-agent: *\nDisallow: /"
    end
  end

  context 'when indexing is allowed' do
    before do
      allow(ENV).to receive(:fetch).with('ALLOW_INDEXING', false).and_return('true')
    end

    it 'makes this clear' do
      get '/robots.txt'
      expect(response.body.chomp).to eq 'User-agent: *'
    end
  end
end
