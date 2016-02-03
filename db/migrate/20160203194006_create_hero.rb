class CreateHero < ActiveRecord::Migration
  def change
    create_table :heroes do |t|
      t.string :name
    end
  end
end
