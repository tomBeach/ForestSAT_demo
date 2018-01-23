class AbstractAuthor < ApplicationRecord
    belongs_to :author
    belongs_to :abstract
end
