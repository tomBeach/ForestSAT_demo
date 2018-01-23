class AddReviewerBooleanToUser < ActiveRecord::Migration[5.1]
  def change
      add_column :users, :reviewer, :boolean
  end
end
