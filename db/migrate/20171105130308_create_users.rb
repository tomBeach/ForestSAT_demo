class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :firstname
      t.string :lastname
      t.string :username
      t.string :password
      t.boolean :submitter
      t.boolean :reviewer
      t.boolean :admin

      t.timestamps
    end
  end
end

# firstname, lastname, username, password, institution, department, user_type, admin
