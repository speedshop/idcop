class CreateAlbums < ActiveRecord::Migration[7.2]
  def change
    create_table :albums do |t|
      t.string :title
      t.string :comment_id

      t.timestamps
    end
  end
end
