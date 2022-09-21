class CreateCountries < ActiveRecord::Migration[7.0]
  def change
    create_table :countries, id: :uuid do |t|
      t.string :code, null: false, index: {unique: true}
      t.string :name, null: false, index: {unique: true}

      t.timestamps
    end
  end
end
