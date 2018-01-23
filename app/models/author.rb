class Author < ApplicationRecord
    has_one :affiliation
    has_one :presentation_as_session_org, :class_name => 'Presentation', :foreign_key => 'session_org_id'
    has_one :presentation_as_session_chair, :class_name => 'Presentation', :foreign_key => 'session_chair_id'
    has_many :abstract_authors
    has_many :abstracts, :through => :abstract_authors
    has_many :author_affiliations
    has_many :affiliations, :through => :author_affiliations
    validates_uniqueness_of :firstname, :lastname

    # ======= full_name =======
    def full_name
        # puts "******* full_name *******"
        if !firstname.nil? && !lastname.nil?
            firstname + " " + lastname
        elsif !firstname.nil?
            firstname
        elsif !lastname.nil?
            lastname
        end
    end

    # ======= get_author =======
    def self.get_author(firstname, lastname)
        puts "******* get_author *******"
        self.where(:firstname => firstname, :lastname => lastname).first
    end


end
