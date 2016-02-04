class CreateCalendar < ActiveRecord::Migration
  def change
    create_table :calendars do |t|
      t.datetime :date
      t.integer :heroes_id
      t.integer :starting_orders_id
      t.integer :switch_flag
    end    
  end
end
