class CreateAuthorAffiliations < ActiveRecord::Migration[5.1]
  def change
    create_table :author_affiliations do |t|
      t.references :author, foreign_key: true
      t.references :affiliation, foreign_key: true

      t.timestamps
    end
  end
end
