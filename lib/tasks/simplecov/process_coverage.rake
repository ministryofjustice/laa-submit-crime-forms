# frozen_string_literal: true

if ENV['CI']
  namespace :simplecov do
    desc 'Process coverage results'
    task process_coverage: :environment do
      require 'simplecov'
      require 'json'

      begin
        SimpleCov.collate Dir['./coverage_results/**/.resultset*.json'], 'rails' do
          enable_coverage :branch
          primary_coverage :branch
          minimum_coverage branch: 100, line: 100
          refuse_coverage_drop :line, :branch
        end
      rescue SystemExit => e
        # Coverage check failed - write summary to GitHub step summary and annotate uncovered lines
        resultset = JSON.parse(File.read('coverage/.resultset.json'))

        # Flatten all coverage data from all subprocess results
        all_coverage = {}
        resultset.each do |_source, data|
          all_coverage.merge!(data['coverage'])
        end

        # Annotate uncovered line ranges
        all_coverage.each do |file_path, file_data|
          next unless file_data['lines']

          relative_path = file_path.sub(%r{^\./}, '')
          range_start = nil

          file_data['lines'].each_with_index do |coverage, line_index|
            is_uncovered = coverage.nil? ? false : coverage == 0

            if is_uncovered
              range_start ||= line_index + 1
            elsif range_start
              # End of uncovered range
              puts "::error file=#{relative_path},line=#{range_start},endLine=#{line_index},title=Uncovered lines::Lines #{range_start}-#{line_index} are not covered by tests"
              range_start = nil
            end
          end

          # Handle uncovered range at end of file
          if range_start
            last_line = file_data['lines'].length
            puts "::error file=#{relative_path},line=#{range_start},endLine=#{last_line},title=Uncovered lines::Lines #{range_start}-#{last_line} are not covered by tests"
          end
        end

        raise e
      end
    end
  end
end
