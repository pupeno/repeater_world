class AddRedistributionLimitationsToRepeaters < ActiveRecord::Migration[7.0]
  def change
    add_column :repeaters, :redistribution_limitations, :string
  end
end
