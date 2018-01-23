class UsersController < ApplicationController
    before_action :set_user, only: [:show]
    # before_action :check_env_vars, only: [:home]

    # ======= home =======
    def home
        puts "\n******* home *******"
        # puts "SENDMAIL_USERNAME: #{SENDMAIL_USERNAME}"
        # puts "SENDMAIL_PASSWORD: #{SENDMAIL_PASSWORD}"
        # puts "MAIL_HOST: #{MAIL_HOST}"

        flash_msg = ""
        @users = User.all

        # == database report (development only)
        if @users == []
            @rooms = Room.all
            @authors = Author.all
            @abstracts = Abstract.all
            @affiliations = Affiliation.all
            puts "+++++++ NO USERS +++++++"
            flash_msg = flash_msg + " NO USERS  "
            if @rooms == []
                puts "+++++++ NO ROOMS +++++++"
                flash_msg = flash_msg + " NO ROOMS  "
            end
            if @authors == []
                puts "+++++++ NO AUTHORS +++++++"
                flash_msg = flash_msg + " NO AUTHORS  "
            end
            if @abstracts == []
                puts "+++++++ NO ABSTRACTS +++++++"
                flash_msg = flash_msg + " NO ABSTRACTS  "
            end
            if @affiliations == []
                puts "+++++++ NO AFFILIATIONS +++++++"
                flash_msg = flash_msg + " NO AFFILIATIONS  "
            end
            flash.now[:notice] = flash_msg
        end
    end

    # ======= signed_in_msg =======
    def signed_in_msg
        puts "\n******* signed_in_msg *******"
    end

    # ======= index =======
    def index
        puts "\n******* index *******"
        @users = User.all         # lists user admins only
    end

    # ======= show =======
    def show
        puts "\n******* show *******"
    end

    # ======= ======= ======= REVIEWERS ======= ======= =======
    # ======= ======= ======= REVIEWERS ======= ======= =======
    # ======= ======= ======= REVIEWERS ======= ======= =======

    # ======= select_reviewers =======
    def select_reviewers
        puts "\n******* select_reviewers *******"
        @wide_flag = true

        # == reviewers must be registered users
        @users = User.all.order("lastname")
    end

    # ======= save_selected_reviewers =======
    def save_selected_reviewers
        puts "\n******* save_selected_reviewers *******"
        puts "params: #{params.inspect}"
        puts "params[:user]: #{params[:user].inspect}"
        puts "params[:controller]: #{params[:controller]}"

        current_reviewer_ids = User.where(:reviewer => true).pluck(:id)
        former_reviewer_ids = []
        notice_string = ""
        notice_array = []

        # == some users have been selected as reviewers (params[:user] not nil)
        if params[:user]
            ok_params = reviewer_status_params

            # == temporarily(?) disallowing removal of reviewers (due to chain-reaction consequences)
            # current_reviewer_ids.each_with_index do |reviewer_id, index|
            #     puts "index: #{index.inspect}"
            #
            #     # == build list of previously selected reviewers
            #     if !ok_params[:reviewer_ids].include? reviewer_id.to_s
            #         former_reviewer_ids << reviewer_id
            #         puts "former_reviewer_ids: #{former_reviewer_ids.inspect}"
            #         former_reviewer = User.find(reviewer_id)
            #
            #         # == set former reviewer boolean to false
            #         former_reviewer.update(:reviewer => false)
            #         puts "notice_array: #{notice_array.inspect}"
            #
            #         # == build list of former reviewers for notice
            #         if former_reviewer_ids.length > 1 && index < current_reviewer_ids.length
            #             notice_array << ", "
            #         end
            #         notice_array << former_reviewer.full_name
            #     end
            # end
            #
            # # == add info prefix to notice array
            # if notice_array.length > 0
            #     notice_array.unshift("Removed reviewers: ")
            # end

            # == change newly selected reviewer status to true
            notice_array.push(" Newly assigned reviewers: ")
            if ok_params[:reviewer_ids].length > 0
                ok_params[:reviewer_ids].each_with_index do |reviewer_id, index|
                    user = User.find(reviewer_id)

                    # == set selected reviewer status to true
                    user.update(:reviewer => true)
                    notice_array.push(user.full_name)
                    if ok_params[:reviewer_ids].length > 1 && index < (ok_params[:reviewer_ids].length - 1)
                        notice_array << ", "
                    end
                end
            end

        # == no users have been selected as reviewers (any previous reviewers status set to false)
        else
            current_reviewer_ids.each do |reviewer_id|
                former_reviewer_ids << reviewer_id
                former_reviewer = User.find(reviewer_id)
                former_reviewer.update(:reviewer => false)
            end
        end

        # == remove former reviewers from abstracts previously assigned
        former_reviewer_ids.each do |reviewer_id|
            abstracts1 = Abstract.where(:reviewer1_id => reviewer_id)
            abstracts1.each do |abstract|
                abstract.update(:reviewer1_id => nil)
            end
            abstracts2 = Abstract.where(:reviewer2_id => reviewer_id)
            abstracts2.each do |abstract|
                abstract.update(:reviewer2_id => nil)
            end
        end
        puts "former_reviewer_ids.length: #{former_reviewer_ids.length.inspect}"
        if ok_params
            puts "ok_params[:reviewer_ids].length: #{ok_params[:reviewer_ids].length.inspect}"
        end
        puts "notice_array: #{notice_array.inspect}"

        # == build notice string from notice array contents
        notice_array.each_with_index do |item, index|
            notice_string += item
        end

        respond_to do |format|
            format.html { redirect_to :select_reviewers, notice: notice_string }
        end
    end

    # ======= assign_reviewers =======
    def assign_reviewers
        puts "\n******* assign_reviewers *******"       # admin screen for assigning reviewers to abstract
        @wide_flag = true
        @reviewers = User.where(:reviewer => true).order("lastname")
        @abstracts = Abstract.all.order("abs_title")
    end

    # ======= save_assigned_reviewers =======
    def save_assigned_reviewers
        puts "\n******* save_assigned_reviewers *******"            # save assign for each abstract (single save disabled)
        ok_params = reviewer_params
        puts "\nok_params: #{ok_params.inspect}"

        # == save all abstract updates
        ok_params[:abstract_ids].each_with_index do |abstract_id, index|
            puts "abstract_id: #{abstract_id.inspect}"
            reviewer1_id = ok_params[:reviewer1_ids][index]
            reviewer2_id = ok_params[:reviewer2_ids][index]

            # == convert empty string values to nil
            if reviewer1_id == ""
                reviewer1_id = nil
            else
                reviewer1_id = reviewer1_id.to_i
            end
            if reviewer2_id == ""
                reviewer2_id = nil
            else
                reviewer2_id = reviewer2_id.to_i
            end

            # == set reviewer ids (if any) for each abstract
            @abstract = Abstract.find(abstract_id)
            puts "@abstract: #{@abstract.inspect}"
            @abstract.update(:reviewer1_id => reviewer1_id, :reviewer2_id => reviewer2_id)
        end
        flash[:notice] = 'All reviewer changes updated successfully.'
        redirect_to :assign_reviewers
    end

    # ======= ======= ======= ADMIN PAGE ======= ======= =======
    # ======= ======= ======= ADMIN PAGE ======= ======= =======
    # ======= ======= ======= ADMIN PAGE ======= ======= =======

    # ======= admin_functions =======
    def admin_functions
        puts "\n******* admin_functions *******"
        @keyword = Keyword.new
        @room = Room.new
        @users = User.where(:admin => true)
    end

    # ======= process_admin_functions =======
    def process_admin_functions
        puts "\n******* admin_functions *******"
        puts "\nparams: #{params.inspect}"
        puts "\nparams[:keyword]: #{params[:keyword].inspect}"

        notice_string = ""

        # == parse returned form values for keywords, rooms, [users, authors, affiliations]
        ok_params = process_admin_params
        keyword_params = ok_params[0]
        room_params = ok_params[1]
        if ok_params[0]
            keyword = keyword_params[:keyword_name]
            puts "\nok_params: #{ok_params.inspect}"
            puts "\nkeyword_params: #{keyword_params.inspect}"
            puts "\nkeyword: #{keyword.inspect}"
        end
        if ok_params[1]
            room = room_params[:room_name]
            puts "\nroom_params: #{room_params.inspect}"
        end

        # == create new keyword
        if keyword
            @keyword = Keyword.new(:keyword_name => keyword, :keyword_category => "1")
            @keyword.save
            if @keyword
                notice_string += " New keyword " + @keyword[:keyword_name] + " saved successfully."
            end
        end

        # == create new room
        if room
            @room = Room.new(:room_name => room, :room_floor => room_params[:room_floor], :room_type => room_params[:room_type])
            @room.save
            if @room
                notice_string += " New room " + @room[:room_name] + " saved successfully."
            end
        end

        flash.now[:notice] = notice_string
        respond_to do |format|
            format.html { redirect_to :admin_functions, notice: notice_string }
        end
    end

    private
        def set_user
            @user = User.find(params[:id])
        end

        def process_admin_params
            puts "******* process_admin_params *******"
            puts "params: #{params.inspect}"
            ok_params = []
            if params[:keyword]
                ok_params << params.require(:keyword).permit(:keyword_name)
            else
                ok_params << nil
            end
            if params[:room]
                ok_params << params.require(:room).permit(:room_name, :room_floor, :room_type)
            else
                ok_params << nil
            end
            return ok_params
        end

        def reviewer_status_params
            puts "******* reviewer_status_params *******"
            params.require(:user).permit(:reviewer_ids => [])
        end

        def reviewer_params
            puts "******* reviewer_params *******"
            params.require(:abstract).permit(:abstract_ids => [], :reviewer1_ids => [], :reviewer2_ids => [])
        end

end
