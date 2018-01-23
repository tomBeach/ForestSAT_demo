class AddAcceptedToAbstracts < ActiveRecord::Migration[5.1]
  def change
      add_column :abstracts, :accepted, :boolean
  end
end
