class CreateLocations < ActiveRecord::Migration
  def change
    drop_table :locations
    create_table :locations do |t|
      t.integer :user_id
      t.float :Longitude
      t.float :Latitude
      t.string :Address
      t.string :Name

      t.timestamps

    end
  end
end
