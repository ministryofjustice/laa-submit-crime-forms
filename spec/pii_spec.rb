require 'rails_helper'

RSpec.describe 'PII' do
  describe 'pii.yml' do
    let(:ignored_tables) { %w[schema_migrations ar_internal_metadata] }
    let(:ignored_columns) { %w[created_at id updated_at] }
    let(:pii_definitions) { YAML.load_file(Rails.root.join('config/pii.yml')) }

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

  describe 'PAA schema' do
    let(:schema_file) { JSON.load_file(Rails.root.join('config/schemas/crm4.json')) }

    it 'explicitly marks every property as PII or not' do
      checker = lambda do |properties, parent_attributes|
        properties.each do |name, attributes|
          if attributes['type'] == 'object'
            checker.call(attributes['properties'], parent_attributes + [name])
          else
            expect(attributes['x-pii']).not_to(
              be_nil,
              "#{parent_attributes.join('->')}->#{name} does not have a PII definition"
            )
          end
        end
      end

      checker.call(schema_file['properties'], [])
    end
  end
end
