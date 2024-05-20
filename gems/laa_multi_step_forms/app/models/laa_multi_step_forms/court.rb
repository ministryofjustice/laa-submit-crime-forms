module LaaMultiStepForms
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
          binding.pry
          rows.map { |r| new(name: r['combined_court_name']) }
              .sort_by(&:name)
        end
      end

      def csv_file_path
        file = File.join(File.dirname(__dir__), '../../config/courts.csv', filename)
        File.read(file)
      end

      def csv_data
        @csv_data ||= CSV.parse(csv_file_path, col_sep: ",", row_sep: :auto, headers: true, skip_blanks: true)
      end
    end
  end
end
