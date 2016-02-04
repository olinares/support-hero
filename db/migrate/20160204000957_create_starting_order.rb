class CreateStartingOrder < ActiveRecord::Migration
  def change
    create_table :starting_orders do |t|
      t.belongs_to :heroes, index: true
      t.integer :heroes_id
      t.integer :list_order
    end
  end
end
