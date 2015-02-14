class CreateMsgs < ActiveRecord::Migration
  def change
    create_table :msgs do |t|
      t.string :name, limit: 256

      t.timestamps null: false
    end
  end
end
