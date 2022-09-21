class CreateRepeaters < ActiveRecord::Migration[7.0]
  def change
    create_table :repeaters, id: :uuid do |t|
      t.string :name
      t.string :call_sign
      t.string :band
      t.string :channel
      t.decimal :tx_frequency
      t.decimal :rx_frequency
      t.string :grid_square
      t.decimal :latitude
      t.decimal :longitude
      t.string :keeper
      t.timestamps
    end
  end
end
