class ChangeColumnLaterToBigint < ActiveRecord::Migration[7.2]
  def change
    change_column :albums, :comment_id, :bigint
  end
end
