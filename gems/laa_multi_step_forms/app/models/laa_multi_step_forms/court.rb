module LaaMultiStepForms
  require 'csv'
  class Court
    def initialize(name:)
      @name = name
    end

    attr_reader :name

    def ==(other)
      other.name == name
    end

    class << self
      def all
        @all ||= begin
          rows = csv_data
          rows.map { |r| new(name: r['combined_formatted']) }
              .sort_by(&:name)
        end
      end

      def csv_file_path
        file = File.join(File.dirname(__dir__), '../../config/courts.csv')
        File.read(file)
      end

      def csv_data
        @csv_data ||= CSV.parse(csv_file_path, col_sep: ',', row_sep: :auto, headers: true, skip_blanks: true)
      end
    end
  end
end
