class Abstract < ApplicationRecord
    belongs_to :corr_author, :class_name => 'User'
    has_many :abstract_authors
    has_many :authors, :through => :abstract_authors, dependent: :destroy

    validates :reviewer1_id, numericality: { allow_nil: true }
    validates :reviewer2_id, numericality: { allow_nil: true }
    validates :abs_title, presence: true
    validates :abs_text, presence: true
    validates :corr_author_id, presence: true
    validates :pres_author_id, presence: true
end
