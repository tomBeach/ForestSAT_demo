class Presentation < ApplicationRecord
    belongs_to :room
    belongs_to :session_org, :class_name => 'Author'
    belongs_to :session_chair, :class_name => 'Author'
    has_many :abstracts
end
