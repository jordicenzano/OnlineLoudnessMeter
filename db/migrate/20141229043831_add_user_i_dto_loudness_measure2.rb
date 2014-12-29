class AddUserIDtoLoudnessMeasure2 < ActiveRecord::Migration
  def change
  	add_column :loudness_measures, :user_id, :integer, :default => 1
  	add_index :loudness_measures, :user_id
  end
end
