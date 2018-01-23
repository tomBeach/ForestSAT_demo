class AddSessionToAbstract < ActiveRecord::Migration[5.1]
    def change
        add_reference :abstracts, :presentations, index: true
    end
end
