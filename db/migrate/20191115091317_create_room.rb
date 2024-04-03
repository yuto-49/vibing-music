class CreateRoom < ActiveRecord::Migration[5.2]
  def change
    create_table :rooms do |t|
      t.references :user
      t.string :title
      t.timestamps null: false
      t.integer :number
      t.string :artist
      t.string :youtubekeyword
   end
  end
end
