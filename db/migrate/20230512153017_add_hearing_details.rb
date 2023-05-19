class AddHearingDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :claims, :first_hearing_date, :date
    add_column :claims, :number_of_hearing, :int
    add_column :claims, :court, :string
    add_column :claims, :in_area, :string
    add_column :claims, :youth_count, :string
    add_column :claims, :hearing_outcome, :string
    add_column :claims, :matter_type, :string
  end
end
