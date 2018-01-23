class AddReviewerGradesToAbstract < ActiveRecord::Migration[5.1]
  def change
      add_column :abstracts, :reviewer1_grade, :string
      add_column :abstracts, :reviewer2_grade, :string
      add_column :abstracts, :admin_final, :string
  end
end
