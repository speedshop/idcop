class CreatePhotos < ActiveRecord::Migration[7.2]
  def change
    create_table :photos do |t|
      t.string :title
      t.integer :album_id

      t.timestamps
    end
  end
end
