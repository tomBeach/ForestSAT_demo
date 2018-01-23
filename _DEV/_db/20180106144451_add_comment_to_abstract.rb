class AddCommentToAbstract < ActiveRecord::Migration[5.1]
    def change
        add_column :abstracts, :abs_comment, :string
    end
end
