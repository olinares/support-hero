class CreateHoliday < ActiveRecord::Migration
  def change
    create_table :holidays do |t|
      t.datetime :date
      t.string :holidayName
    end
  end
end
