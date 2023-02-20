class RefactorLocationFieldsInRepeaterAndSuggestedRepeaters < ActiveRecord::Migration[7.0]
  def change
    remove_column :repeaters, :region_1
    remove_column :repeaters, :region_2
    remove_column :repeaters, :region_3
    remove_column :repeaters, :region_4
    remove_column :repeaters, :country_id

    add_column :repeaters, :address, :string
    add_column :repeaters, :locality, :string
    add_column :repeaters, :region, :string
    add_column :repeaters, :post_code, :string
    add_reference :repeaters, :country, foreign_key: true, type: :string

    remove_column :suggested_repeaters, :region_1
    remove_column :suggested_repeaters, :region_2
    remove_column :suggested_repeaters, :region_3
    remove_column :suggested_repeaters, :region_4
    remove_column :suggested_repeaters, :country

    add_column :suggested_repeaters, :address, :string
    add_column :suggested_repeaters, :locality, :string
    add_column :suggested_repeaters, :region, :string
    add_column :suggested_repeaters, :post_code, :string
    add_column :suggested_repeaters, :country, :string
  end
end
