class CreateLoudnessMeasures < ActiveRecord::Migration
  def change
    create_table :loudness_measures do |t|
      t.string :name
      t.string :state
      t.text :obs
      t.text :url
   		t.float :loudnessi
   		t.float :loudnesslra
      t.interger :user_id

      t.timestamps
    end
  end
end
