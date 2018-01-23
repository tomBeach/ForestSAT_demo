class CreateKeywords < ActiveRecord::Migration[5.1]
  def change
    create_table :keywords do |t|
      t.string :keyword_name
      t.string :keyword_category

      t.timestamps
    end
  end
end
