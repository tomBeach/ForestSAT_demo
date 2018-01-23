class Affiliation < ApplicationRecord
    has_many :author_affilitions
    has_many :authors, :through => :author_affilitions
end
