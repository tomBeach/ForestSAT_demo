class CreatePresentations < ActiveRecord::Migration[5.1]
  def change
    create_table :presentations do |t|
      t.references :session_org
      t.references :session_chair
      t.references :room, foreign_key: true
      t.string :session_type
      t.string :session_title
      t.datetime :session_start

      t.timestamps
    end
  end
end

# session_org, session_chair, room, session_type, session_title, session_start,
