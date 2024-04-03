class CreateParty < ActiveRecord::Migration[5.2]
  def change
    create_table :parties do |t|
      t.references :user
      t.references :room
    end
  end
end
