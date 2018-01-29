class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
  	before_action :configure_permitted_parameters, if: :devise_controller?
  	before_action :authenticate_user!, except: [:home, :signed_in_msg, :faq]
    before_action :check_login_state

    require "yaml"

    def check_login_state
        puts "******* check_login_state *******"
        if current_user
            @reviewer_abstracts = Abstract.select(:id, :abs_title).where("reviewer1_id = ? OR reviewer2_id = ?", current_user[:id], current_user[:id])
            if @reviewer_abstracts
                puts "@reviewer_abstracts: #{@reviewer_abstracts.inspect}"
            end
        end
    end

    protected
    	def configure_permitted_parameters
            puts "******* configure_permitted_parameters *******"
    		devise_parameter_sanitizer.permit(:sign_in) do |u|
    			u.permit({ roles: [] }, :username, :password, :remember_me)
    		end
    		devise_parameter_sanitizer.permit(:sign_up) do |u|
    			u.permit({ roles: [] }, :affiliation_id, :firstname, :lastname, :username, :password, :password_confirmation, :email)
    		end
    		devise_parameter_sanitizer.permit(:account_update) do |u|
    			u.permit({ roles: [] }, :affiliation_id, :firstname, :lastname, :username, :current_password, :password, :password_confirmation, :email)
    		end
    	end

        def after_sign_in_path_for(resource)
            puts "******* after_sign_in_path_for *******"
            puts "resource: #{resource.inspect}"

            # == check if user/author already in database
            @check_author = Author.where(:firstname => current_user[:firstname], :lastname => current_user[:lastname]).first

            # == link existing author to user via user_id
            if @check_author
                if !@check_author[:user_id]
                    @check_author.update(:user_id => current_user[:id])
                    puts "@check_author: #{@check_author.inspect}"
                end
            end
            home_path
        end

end
