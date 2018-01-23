class CreateAbstracts < ActiveRecord::Migration[5.1]
  def change
    create_table :abstracts do |t|
      t.references :corr_author
      t.references :pres_author
      t.references :reviewer1
      t.references :reviewer2
      t.references :presentation, foreign_key: true
      t.integer :session_sequence
      t.string :abs_title
      t.string :abs_text
      t.string :keyword_1
      t.string :keyword_2
      t.string :keyword_3
      t.string :present_request
      t.string :present_assigned
      t.string :reviewer1_rec
      t.string :reviewer2_rec
      t.string :reviewer1_grade
      t.string :reviewer2_grade
      t.string :reviewer1_comment
      t.string :reviewer2_comment
      t.boolean :reviewer1_keywords, :default => true
      t.boolean :reviewer2_keywords, :default => true
      t.boolean :accepted
      t.boolean :invited
      t.boolean :paper
      t.string :admin_final

      t.timestamps
    end
  end
end

# corr_author_id, pres_author_id, reviewer1_id, reviewer2_id, presentation_id, session_sequence, abs_title, abs_text, keyword_1, keyword_2, keyword_3, present_request, present_assigned, reviewer1_rec, reviewer2_rec, accepted, invited, paper
