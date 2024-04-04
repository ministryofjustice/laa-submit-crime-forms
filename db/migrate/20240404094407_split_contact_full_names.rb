class SplitContactFullNames < ActiveRecord::Migration[7.1]
  def change
    change_table :quotes, bulk: true do |t|
      t.remove :contact_full_name, type: :string
      t.string :contact_first_name, type: :string
      t.string :contact_last_name, type: :string
    end

    change_table :solicitors, bulk: true do |t|
      t.remove :contact_full_name, type: :string
      t.string :contact_first_name, type: :string
      t.string :contact_last_name, type: :string
      t.remove :full_name, type: :string
      t.string :first_name, type: :string
      t.string :last_name, type: :string
    end
  end
end
