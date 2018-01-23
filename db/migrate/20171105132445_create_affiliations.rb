class CreateAffiliations < ActiveRecord::Migration[5.1]
  def change
    create_table :affiliations do |t|
      t.string :institution
      t.string :department

      t.timestamps
    end
  end
end
