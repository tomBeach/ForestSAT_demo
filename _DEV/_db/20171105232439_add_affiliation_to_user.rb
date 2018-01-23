class AddAffiliationToUser < ActiveRecord::Migration[5.1]
    def change
        add_column :users, :affiliation_id, :integer
    end
end
