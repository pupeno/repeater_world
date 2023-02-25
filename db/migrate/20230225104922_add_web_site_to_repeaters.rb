class AddWebSiteToRepeaters < ActiveRecord::Migration[7.0]
  def change
    add_column :repeaters, :web_site, :string
  end
end
