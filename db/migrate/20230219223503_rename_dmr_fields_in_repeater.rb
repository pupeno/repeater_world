class RenameDmrFieldsInRepeater < ActiveRecord::Migration[7.0]
  def change
    rename_column :repeaters, :dmr_cc, :dmr_color_code
    rename_column :repeaters, :dmr_con, :dmr_network
  end
end
