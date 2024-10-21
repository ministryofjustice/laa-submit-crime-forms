require 'rails_helper'

RSpec.describe 'PII' do
  describe 'pii.yml' do
    let(:ignored_tables) { %w[schema_migrations ar_internal_metadata solid_cache_entries] }
    let(:ignored_columns) { %w[created_at id updated_at] }
    let(:pii_definitions) { YAML.load_file(Rails.root.join('db/pii.yml')) }

    it 'explicitly marks every database column as either PII or not' do
      ActiveRecord::Base.connection.tables.each do |table_name|
        next if ignored_tables.include?(table_name)

        (ActiveRecord::Base.connection.columns(table_name).map(&:name) - ignored_columns).each do |column_name|
          expect(pii_definitions.dig(table_name, column_name)).not_to(
            be_nil,
            "Table column #{table_name}.#{column_name} has not been listed in config/pii.yml"
          )
        end
      end
    end
  end
end
