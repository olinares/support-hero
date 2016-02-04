class CreateUnavailable < ActiveRecord::Migration
  def change
    create_table :unavailables do |t|
      t.datetime :date
      t.integer :heroes_id
    end
  end
end
