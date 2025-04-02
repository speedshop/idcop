class Addmissingindex < ActiveRecord::Migration[7.2]
  def change
    add_column :foos, :foreign_id, :bigint
  end
end
