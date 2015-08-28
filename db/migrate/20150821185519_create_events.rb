class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :user_id
      t.datetime :Start
      t.string :Day
      t.integer :location_id

      t.timestamps

    end
  end
end
