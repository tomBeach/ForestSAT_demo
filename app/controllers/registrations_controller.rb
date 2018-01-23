class RegistrationsController < Devise::RegistrationsController
    before_action :get_affiliations, only: [:new, :edit]

    @@abstract_flag = false

    # ======= handle_errors =======
    def handle_errors
        puts "\n******* handle_errors *******"
        # render json: { tags: @tags, post_no_tags: @post_no_tags, post_id: @post_id}
    end

    # ======= get_affiliations =======
    def get_affiliations
        puts "******* get_affiliations *******"
        @affiliations = Affiliation.all
    end

    private

        # ======= after_inactive_sign_up_path_for =======
        def after_inactive_sign_up_path_for(resource)
            puts "\n******* after_inactive_sign_up_path_for *******"
            puts "resource: #{resource.inspect}"
            @msg_flag = "show_msg"
            signed_in_msg_path
        end

        # ======= after_sign_up_path_for =======
        def after_sign_up_path_for(resource)
            puts "\n******* after_sign_up_path_for *******"
            puts "resource: #{resource.inspect}"

            # == check if user/author already in database
            @check_author = Author.where(:firstname => current_user[:firstname], :lastname => current_user[:lastname]).first

            # == link existing autor to user via user_id
            if @check_author
                @check_author.update(:user_id => current_user[:id])
                puts "@check_author: #{@check_author.inspect}"
            end

            puts "@@abstract_flag: #{@@abstract_flag.inspect}"
            if @@abstract_flag == true
                puts "+++ ABSTRACT TRUE +++"
                @@abstract_flag = false
                new_abstract_path
            else
                puts "+++ ABSTRACT FALSE +++"
                if current_user
                    if current_user[:confirmed_at] == nil
                        flash.now[:notice] = "Welcome to ForestSat 2018. Please confirm your email account before signing in."
                    else
                        flash.now[:notice] = "Welcome to ForestSat 2018."
                    end
                end
                puts "+++ new_user_session_path +++"
                home_path
            end
        end

        # ======= after_update_path_for =======
        def after_update_path_for(resource)
            puts "\n******* after_update_path_for *******"
            signed_in_root_path(resource)
        end

        def sign_up_params
            puts "******* sign_up_params *******"
            puts "params: #{params.inspect}"
            if params[:user][:abstract_flag] == "true"
                @@abstract_flag = true
            end
            params[:user].delete :abstract_flag
            params.require(:user).permit(:firstname, :lastname, :institution, :department, :username, :password, :password_confirmation, :email, :admin)
        end

        def account_update_params
            puts "******* account_update_params *******"
            params.require(:user).permit(:firstname, :lastname, :institution, :department, :username, :current_password, :password, :password_confirmation, :email, :admin)
        end
end
