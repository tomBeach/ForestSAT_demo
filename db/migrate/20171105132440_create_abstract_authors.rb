class CreateAbstractAuthors < ActiveRecord::Migration[5.1]
  def change
    create_table :abstract_authors do |t|
      t.references :author, foreign_key: true
      t.references :abstract, foreign_key: true
      t.string :author_type

      t.timestamps
    end
  end
end
