class CreateFoos < ActiveRecord::Migration[7.2]
  def change
    create_table :foos do |t|
      t.integer :bar_id

      t.timestamps
    end
  end
end
