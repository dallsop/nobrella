class CreateEvents < ActiveRecord::Migration
  def change
    drop_table :events
    create_table :events do |t|
      t.datetime :Start
      t.string :Day
      t.integer :location_id

      t.timestamps

    end
  end
end
