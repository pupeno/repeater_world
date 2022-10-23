class CreateRepeaters < ActiveRecord::Migration[7.0]
  def change
    create_table :repeaters, id: :uuid do |t|
      t.string :name
      t.string :call_sign, index: true
      t.string :band
      t.string :channel
      t.decimal :tx_frequency
      t.decimal :rx_frequency
      t.string :keeper

      t.string :grid_square
      t.decimal :latitude
      t.decimal :longitude
      t.references :country, foreign_key: true, type: :string
      t.string :region_1
      t.string :region_2
      t.string :region_3
      t.string :region_4

      t.timestamps
    end


  end
end
