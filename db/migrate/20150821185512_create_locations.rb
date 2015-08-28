class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.integer :user_id
      t.float :longitude
      t.float :latitude
      t.string :address
      t.string :name

      t.timestamps

    end
  end
end
