class AddKeywordsOkToAbstracts < ActiveRecord::Migration[5.1]
    def change
        add_column :abstracts, :rev1_keywords_ok, :boolean, :default => true
        add_column :abstracts, :rev2_keywords_ok, :boolean, :default => true
    end
end
