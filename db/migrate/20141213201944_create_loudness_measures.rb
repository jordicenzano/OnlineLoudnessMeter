class CreateLoudnessMeasures < ActiveRecord::Migration
  def change
    create_table :loudness_measures do |t|
      	t.string :name
      	t.string :state
      	t.text :obs
      	t.text :originalfilename
   		t.text :localfilename
   		t.float :loudnessi
   		t.float :loudnesslra

      	t.timestamps
    end
  end
end
