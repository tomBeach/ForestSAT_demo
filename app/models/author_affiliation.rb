class AuthorAffiliation < ApplicationRecord
  belongs_to :author
  belongs_to :affiliation
end
