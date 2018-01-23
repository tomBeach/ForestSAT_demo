class ConfirmationsController < Devise::ConfirmationsController

    # ======= new =======
    def new
        puts "\n******* new *******"
        super
    end

    # ======= create =======
    def create
        puts "\n******* create *******"
        super
    end

    # ======= show =======
    def show
        puts "\n******* show *******"
        self.resource = resource_class.confirm_by_token(params[:confirmation_token])

        if resource.errors.empty?
            set_flash_message(:notice, :confirmed) if is_navigational_format?
            # sign_in(resource_name, resource)
            respond_with_navigational(resource) {
                sign_in(resource_name, resource)
                # redirect_to confirmation_getting_started_path
            }
        else
            respond_with_navigational(resource.errors, :status => :unprocessable_entity) {
                render_with_scope :new
            }
        end
    end

    private

        # ======= after_confirmation_path_for =======
            # def after_confirmation_path_for(resource_name, resource)
            #     puts "\n******* after_confirmation_path_for *******"
            #     puts "resource_name: #{resource_name.inspect}"
            #     puts "resource: #{resource.inspect}"
            #     signed_in_msg_path
            # end

    # protected
    #
    #     # The path used after resending confirmation instructions.
    #     def after_resending_confirmation_instructions_path_for(resource_name)
    #         puts "\n******* after_resending_confirmation_instructions_path_for *******"
    #         is_navigational_format? ? new_session_path(resource_name) : '/'
    #     end
    #
    #     # The path used after confirmation.
    #     def after_confirmation_path_for(resource_name, resource)
    #         puts "\n******* after_confirmation_path_for *******"
    #         if signed_in?(resource_name)
    #             signed_in_msg_path(resource)
    #         else
    #             new_session_path(resource_name)
    #         end
    #     end

end
