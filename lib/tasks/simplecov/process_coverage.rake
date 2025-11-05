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
        result = SimpleCov::Result.from_hash(JSON.parse(File.read('coverage/.resultset.json')))

        summary = "## Coverage Report\n"
        summary += "- Line coverage: #{format('%.2f', result.line_coverage)}%\n"
        summary += "- Branch coverage: #{format('%.2f', result.branch_coverage)}%\n"

        File.write(ENV.fetch('GITHUB_STEP_SUMMARY', nil), summary, mode: 'a')

        # Annotate uncovered lines
        result.files.each do |file_path, file_coverage|
          next unless file_coverage.lines

          file_coverage.lines.each_with_index do |coverage, line_index|
            next if coverage.nil? || coverage > 0

            relative_path = file_path.sub(%r{^\./}, '')
            puts "::error file=#{relative_path},line=#{line_index + 1}::Line not covered"
          end
        end

        raise e
      end
    end
  end
end
