# frozen_string_literal: true

if ENV['CI']
  namespace :simplecov do
    desc 'Process coverage results'
    task process_coverage: :environment do
      require 'simplecov'

      SimpleCov.collate Dir['./coverage_results/.resultset*.json'], 'rails' do
        enable_coverage :branch
        primary_coverage :branch
        minimum_coverage branch: 100, line: 100
        refuse_coverage_drop :line, :branch
      end
    end
  end
end
