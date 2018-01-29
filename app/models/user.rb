class User < ApplicationRecord
    devise :registerable, :recoverable, :rememberable, :trackable, :confirmable, :database_authenticatable, :authentication_keys => [:username]
    has_many :abstracts_as_corr_author, :class_name => 'Abstract', :foreign_key => 'corr_author_id'

    validates :username, :email, presence: true
    validates :username, :email, uniqueness: true
    validates :password, length: { minimum: 6 }, unless: "password.nil?"
    validates :password, presence: true, if: "id.nil?"

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

    # ======= pre_register_users =======
    def self.pre_register_users
        puts "******* pre_register_users *******"
        self.where(["created_at < ?", Time.now])
    end

end
