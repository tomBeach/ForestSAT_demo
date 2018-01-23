# ======= ======= ======= application.html.erb ======= ======= =======
# ======= ======= ======= application.html.erb ======= ======= =======
# ======= ======= ======= application.html.erb ======= ======= =======

<!DOCTYPE html>
<html>
    <head>
        <title>||| ForestSat |||</title>
        <%= csrf_meta_tags %>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
        <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
        <%= javascript_include_tag 'application', 'data-turbolinks-track': 'reload' %>
    </head>

    <!-- ======= ======= ======= body ======= ======= ======= -->
    <body>
        <div id="pageWrap">

            <!-- ======= menu ======= -->
            <div id="menuBox">
                <div class="menuRow">
                    <div id="signinItems" class="menuGroup">
                        <p class="menuLabel">signin</p>
                        <%= link_to "Home", home_path, class: "menuItem" %>

                        <% if !current_user %>
                            <%= link_to "Sign up", new_user_registration_path, class: "menuItem" %>
                            <%= link_to "Sign in", new_user_session_path, class: "menuItem" %>
                        <% else %>
                            <%= link_to "Sign out", destroy_user_session_path, :method => :delete, class: "menuItem" %>
                            <a href="#" class="menuItem filler"></a>

                    </div>
                    <div id="signinFiller" class="menuGroup">
                        <p class="menuLabel">current user</p>
                        <p id="userFullName" class="filler">
                            <%= current_user[:firstname] + " " + current_user[:lastname] %>
                        </p>
                    </div>
                </div>

                <div class="menuRow">
                    <div id="userItems" class="menuGroup">
                        <p class="menuLabel">users</p>
                        <%= link_to "My Profile", user_path(current_user), class: "menuItem" %>
                    </div>
                    <div id="abstractItems" class="menuGroup">
                        <p class="menuLabel">abstracts</p>
                        <%= link_to "My Abstracts", "/my_abstracts", class: "menuItem" %>
                        <%= link_to "All Abstracts", abstracts_path, class: "menuItem" %>
                        <%= link_to "New Abstract", new_abstract_path, class: "menuItem" %>
                    </div>
                    <div id="reviewItems" class="menuGroup">
                        <p class="menuLabel">reviewers</p>
                        <% if current_user.reviewer? %>
                            <% if @reviewer_abstracts.length > 0 %>
                                <%= link_to "Review Abstracts", "/review_abstracts", class: "menuItem" %>
                                <%= link_to "Review Status", new_presentation_path, class: "menuItem" %>
                            <% else %>
                                <a href="#" class="menuItem filler"></a>
                                <a href="#" class="menuItem filler"></a>
                            <% end %>
                        <% else %>
                            <a href="#" class="menuItem filler"></a>
                            <a href="#" class="menuItem filler"></a>
                        <% end %>
                    </div>
                </div>

            <% if current_user.admin? %>
                <div class="menuRow">
                    <div id="authorItems" class="menuGroup">
                        <p class="menuLabel">authors</p>
                        <%= link_to "All Authors", authors_path, class: "menuItem" %>
                    </div>
                    <div id="adminItems" class="menuGroup">
                        <p class="menuLabel">select/assign reviewers</p>
                        <%= link_to 'Select Reviewers', "/select_reviewers", class: "menuItem" %>
                        <%= link_to "Assign Reviewers", "/assign_reviewers", class: "menuItem" %>
                        <%= link_to "Select Abstracts", "/select_abstracts", class: "menuItem" %>
                    </div>
                    <div id="sessionItems" class="menuGroup">
                        <p class="menuLabel">sessions</p>
                        <%= link_to "List View", rooms_path, class: "menuItem" %>
                        <%= link_to "Chart View", new_room_path, class: "menuItem" %>
                    </div>
                </div>
            <% end %>

                        <% end %>

            </div>

            <!-- ======= messages ======= -->
            <div id="messages">
                <p id="notice"><%= notice %></p>
            </div>

            <!-- ======= yield ======= -->
            <div id="yield" class="section" data-state="default">
                <%= yield %>
            </div>

        </div>

    </body>
</html>


# ======= ======= ======= users_controller.rb ======= ======= =======
# ======= ======= ======= users_controller.rb ======= ======= =======
# ======= ======= ======= users_controller.rb ======= ======= =======

class UsersController < ApplicationController
    before_action :set_user, only: [:show]
    before_action :check_env_vars, only: [:home]

    # ======= home =======
    def home
        flash_msg =""
        @users = User.all
        @rooms = Room.all
        @authors = Author.all
        @abstracts = Abstract.all
        @affiliations = Affiliation.all
        if @users == []
            puts "+++++++ NO USERS +++++++"
            flash_msg = flash_msg + " NO USERS  "
        end
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

    # ======= index =======
    # lists user admins only
    def index
        @users = User.where(:admin => true)
    end

    # ======= select_reviewers =======
    # admin screen for selecting reviewers
    def select_reviewers
        @users = User.all.order("lastname")
    end

    # ======= save_select =======
    # save selected reviewers
    def save_select

        current_reviewer_ids = User.where(:reviewer => true).pluck(:id)
        former_reviewer_ids = []

        # == change un-checked reviewer status to false
        if params[:user]
            ok_params = reviewer_status_params
            current_reviewer_ids.each do |reviewer_id|
                if !ok_params[:reviewer_ids].include? reviewer_id.to_s
                    former_reviewer_ids << reviewer_id
                    former_reviewer = User.find(reviewer_id)
                    former_reviewer.update(:reviewer => false)
                end
            end

            # == change newly selected reviewer status to true
            ok_params[:reviewer_ids].each do |reviewer_id|
                user = User.find(reviewer_id)
                user.update(:reviewer => true)
            end
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
            abstracts2 = Abstract.where(:reviewer2_id => reviewer_id)

            abstracts1.each do |abstract|
                abstract.update(:reviewer1_id => nil)
            end
            abstracts2.each do |abstract|
                abstract.update(:reviewer2_id => nil)
            end
        end
        redirect_to :select_reviewers
    end

    # ======= assign_reviewers =======
    # admin screen for assigning reviewers to abstract
    def assign_reviewers
        @reviewers = User.where(:reviewer => true).order("lastname")
        @abstracts = Abstract.all.order("abs_title")
    end

    # ======= save_assign =======
    # save assign for each abstract (single save disabled)
    def save_assign
        ok_params = reviewer_params

        # == save all abstract updates
        ok_params[:abstract_ids].each_with_index do |abstract_id, index|
            reviewer1_id = ok_params[:reviewer1_ids][index]
            reviewer2_id = ok_params[:reviewer2_ids][index]
            @abstract = Abstract.find(abstract_id)
            @abstract.update(:reviewer1_id => reviewer1_id, :reviewer2_id => reviewer2_id)
        end
        flash[:notice] = 'All reviewer changes updated successfully.'
        redirect_to :assign_reviewers
    end

    # ======= show =======
    def show
        puts "\n******* show *******"
    end

    # ======= check_env_vars =======
    def check_env_vars
        puts "\n******* check_env_vars *******"
        puts "SENDMAIL_USERNAME: #{SENDMAIL_USERNAME}"
        puts "SENDMAIL_PASSWORD: #{SENDMAIL_PASSWORD}"
        puts "MAIL_HOST: #{MAIL_HOST}"
    end

    # ======= my_abstracts =======
    def my_abstracts

        # == get author record for current_user
        author = Author.where(:firstname => current_user.firstname, :lastname => current_user.lastname).first

        # == get abstracts where current_user is primary or secondary author
        abstracts = author.abstracts

        # == get abstracts where current_user is corresponding or presenting author
        corr_abstracts = Abstract.where("corr_author_id = " + current_user[:id].to_s + " OR pres_author_id = " + current_user[:id].to_s)

        # == merge both selections withour duplication
        @abstracts = abstracts + corr_abstracts

        @title = "My Abstracts"
        render :template => 'abstracts/index'
    end

    private
        def set_user
            @user = User.find(params[:id])
        end

        def reviewer_status_params
            params.require(:user).permit(:reviewer_ids => [])
        end

        def reviewer_params
            params.require(:abstract).permit(:abstract_ids => [], :reviewer1_ids => [], :reviewer2_ids => [], :abstract_ids => [])
        end

end


# ======= ======= ======= abstracts_controller.rb ======= ======= =======
# ======= ======= ======= abstracts_controller.rb ======= ======= =======
# ======= ======= ======= abstracts_controller.rb ======= ======= =======

class AbstractsController < ApplicationController
    before_action :set_abstract, only: [:show, :edit, :update, :destroy]

    # ======= index =======
    def index
        @abstracts = Abstract.all
    end

    # ======= signup_abstract =======
    def signup_abstract
        @abstracts = Abstract.all
    end

    # ======= review_abstracts =======
    # == reviewer selects abstracts to review
    def review_abstracts
        @users = User.all.order("lastname")
        @abstracts = Abstract.where("reviewer1_id = ? OR reviewer2_id = ?", current_user[:id], current_user[:id]).order("abs_title")
    end

    # ======= save_all_reviews =======
    # == reviewer selects abstracts to review
    def save_all_reviews
        ok_params = rec_grade_params
        ok_params[:abstract_ids].each_with_index do |abstract_id, index|
            reviewer_rec = ok_params[:reviewer_recs][index]
            reviewer_grade = ok_params[:reviewer_grades][index]
            @abstract = Abstract.find(abstract_id)
            if ok_params[:which_reviewer] == "reviewer1"
                @abstract.update(:reviewer1_rec => reviewer_rec, :reviewer1_grade => reviewer_grade)
            else
                @abstract.update(:reviewer2_rec => reviewer_rec, :reviewer2_grade => reviewer_grade)
            end
        end
        flash[:notice] = 'All abstract changes updated successfully.'
        redirect_to :select_abstracts
    end

    # ======= select_abstracts =======
    # == create admin screen for selecting/rejecting abstracts
    def select_abstracts
        @users = User.all.order("lastname")
        @keywords_1 = Keyword.where(:keyword_category => 1)
        @keywords_2 = Keyword.where(:keyword_category => 2)
        @keywords_3 = Keyword.where(:keyword_category => 3)
        @abstracts = Abstract.all.order("abs_title")
    end

    # ======= save_selection =======
    # == save admin selection ()
    def save_selection
        ok_params = selection_params
        if ok_params[:abstract_id] == "all"
            ok_params[:abstract_ids].each_with_index do |abstract_id, index|
                admin_final = ok_params[:admin_finals][index]
                @abstract = Abstract.find(abstract_id)
                @abstract.update(:admin_final => admin_final)
            end
            flash[:notice] = 'All abstract changes updated successfully.'
            redirect_to :select_abstracts
        else
            flash[:notice] = 'Selected abstract status updated successfully.'
            @abstract = Abstract.find(ok_params[:abstract_id])
            @abstract.update(:admin_final => ok_params[:admin_final])
            redirect_to :select_abstracts
        end
    end

    # ======= filter_by_keyword =======
    # == any combination of three keywords can be used for filtering
    def filter_by_keyword
        ok_params = filter_params

        query_array = []
        value_array = []
        keyword_array = []
        query_string = ""
        value_string = ""
        keyword_string = ""
        if params[:keyword_1].length > 0
            keyword_1 = Keyword.select(:keyword_name).find(params[:keyword_1])
            keyword_array << keyword_1
            value_array << params[:keyword_1]
            query_array << "keyword_1 = ?"
        end
        if params[:keyword_2].length > 0
            keyword_2 = Keyword.select(:keyword_name).find(params[:keyword_2])
            keyword_array << keyword_2
            value_array << params[:keyword_2]
            query_array << "keyword_2 = ?"
        end
        if params[:keyword_3].length > 0
            keyword_3 = Keyword.select(:keyword_name).find(params[:keyword_3])
            keyword_array << keyword_3
            value_array << params[:keyword_3]
            query_array << "keyword_3 = ?"
        end

        # == build query based on non-nil keyword values
        if keyword_array.length > 0
            keyword_array.each_with_index do |keyword, index|
                keyword_string += keyword[:keyword_name]
                query_string += query_array[index]
                if index < (keyword_array.length - 1)
                    keyword_string += " OR "
                    query_string += " OR "
                end
            end
        end
        value_array = value_array.unshift(query_string)

        @abstracts = Abstract.where(value_array)

        # == get current keyword lists by type
        @users = User.all.order("lastname")
        @keywords_1 = Keyword.where(:keyword_category => 1)
        @keywords_2 = Keyword.where(:keyword_category => 2)
        @keywords_3 = Keyword.where(:keyword_category => 3)
        flash.now[:notice] = "Selection by keywords: " + keyword_string
        respond_to do |format|
            format.html { render :select_abstracts }
        end
    end

    # ======= edit =======
    def edit
        @users = User.all

        # == get author data from authors and abstract_authors
        sql = "SELECT authors.id, authors.firstname, authors.lastname, abstract_authors.author_type FROM authors INNER JOIN abstract_authors ON authors.id = abstract_authors.author_id WHERE abstract_authors.abstract_id = '" + @abstract[:id].to_s + "';"
        @authors_data = ActiveRecord::Base.connection.execute(sql)

        @keywords_1 = Keyword.where(:keyword_category => 1)
        @keywords_2 = Keyword.where(:keyword_category => 2)
        @keywords_3 = Keyword.where(:keyword_category => 3)
    end

    # ======= update =======
    def update
        ok_params = update_params
        respond_to do |format|
            if @abstract.update(ok_params)
                format.html { redirect_to @abstract, notice: 'Abstract was successfully updated.' }
            else
                format.html { render :edit }
            end
        end
    end

    # ======= new =======
    def new
        @users = User.all.order("lastname")
        @keywords1 = Keyword.where(:keyword_category => "1")
        @keywords2 = Keyword.where(:keyword_category => "2")
        @keywords3 = Keyword.where(:keyword_category => "3")
        @affiliations = Affiliation.all
        @abstract_author = AbstractAuthor.new
        @affiliation = Affiliation.new
        @abstract = Abstract.new
        @author = Author.new
        if current_user[:admin] == true
            @admin_flag = true
        else
            @admin_flag = false
        end
    end

    # ======= create =======
    def create

        # == extract abstract/author/affiliation values from params
        ok_params = abstract_params
        abs_params = ok_params[0]
        author_params = ok_params[1]
        affiliation_params = ok_params[2]
        author_type_params = ok_params[3]
        pres_author_index = abs_params[:pres_author_id]

        if abs_params[:new_keyword_1] != ""
            @keyword1 = Keyword.create(:keyword_name => abs_params[:new_keyword_1], :keyword_category => "1")
            if @keyword1
                abs_params[:keyword_1] = @keyword1[:id]
            else
                flash.now[:notice] = "There was a problem with the new keyword_1."
            end
        end
        if abs_params[:new_keyword_2] != ""
            @keyword2 = Keyword.create(:keyword_name => abs_params[:new_keyword_2], :keyword_category => "2")
            if @keyword2
                abs_params[:keyword_2] = @keyword2[:id]
            else
                flash.now[:notice] = "There was a problem with the new keyword_2."
            end
        end
        if abs_params[:new_keyword_3] != ""
            @keyword3 = Keyword.create(:keyword_name => abs_params[:new_keyword_3], :keyword_category => "3")
            if @keyword3
                abs_params[:keyword_3] = @keyword3[:id]
            else
                flash.now[:notice] = "There was a problem with the new keyword_3."
            end
        end
        abs_params = abs_params.except(:new_keyword_1)
        abs_params = abs_params.except(:new_keyword_2)
        abs_params = abs_params.except(:new_keyword_3)

        @abstract = Abstract.new(abs_params)

        # == save abstract
        respond_to do |format|
            if @abstract.save

                # == loop through author params arrays (firstnames/lastnames/author_types)
                author_params[:firstnames].each_with_index do |firstname, index|
                    lastname = author_params[:lastnames][index]
                    institution = affiliation_params[:institutions][index]
                    department = affiliation_params[:departments][index]
                    author_type = author_type_params[:author_types][index]
                    @author = Author.where(:firstname => firstname, :lastname => lastname).first

                    current_user_fname = current_user[:firstname]
                    current_user_lname = current_user[:lastname]

                    # == check if current_user is one of the authors
                    if current_user_fname == firstname && current_user_lname == lastname
                        user_id = current_user[:id]
                    else
                        user_id = nil
                    end

                    # == author not in database; create new author
                    if !@author
                        @author = Author.new(:firstname => firstname, :lastname => lastname, :user_id => user_id)

                        # == save author
                        if @author.save
                            @author = Author.order("created_at").last

                            # == check if author is selected as presenting author
                            if index == pres_author_index.to_i
                                @abstract.update(:pres_author_id => @author[:id])
                                @pres_author = Author.find(@author[:id])
                            end

                            # == create join table abstract/author link with author_type
                            @abstract_author = AbstractAuthor.new(:abstract_id => @abstract[:id].to_i, :author_id => @author[:id].to_i, :author_type => author_type)
                            if @abstract_author.save
                                puts "++++++ abstract_author NEW OK +++++++"
                            else
                                flash[:notice] = 'Join table save failed.  Please try again.'
                            end

                            # == save affiliation
                            @affiliation = Affiliation.where(:institution => institution, :department => department).first
                            if !@affiliation
                                @affiliation = Affiliation.new(:author_id => @author[:id], :institution => institution, :department => department)
                                if @affiliation.save
                                    puts "++++++ affiliation NEW OK +++++++"
                                else
                                    flash[:notice] = 'Affiliation save failed.  Please try again.'
                                end
                            end
                        end

                    # == author already in database; create join table abstract/author link with author_type
                    else

                        if index == pres_author_index.to_i
                            @abstract.update(:pres_author_id => @author[:id])
                            @pres_author = Author.find(@author[:id])
                        end

                        @abstract_author = AbstractAuthor.new(:abstract_id => @abstract[:id].to_i, :author_id => @author[:id].to_i, :author_type => author_type)
                        if @abstract_author.save
                            puts "++++++ abstract_author NEW OK +++++++"
                        else
                            flash[:notice] = 'Join table save failed.  Please try again.'
                        end
                    end
                end
                abstract_authors = @abstract.authors
                format.html { redirect_to @abstract, notice: 'Abstract/author/join all successfully created.' }
            else
                @users = User.all.order("lastname")
                @affiliations = Affiliation.all
                @affiliation = Affiliation.new
                @abstract = Abstract.new
                @author = Author.new
                flash[:notice] = 'There was a problem saving your abstract. Please try again.'
                format.html { render :new }
            end
        end

    end

    # ======= show =======
    def show

        @edit_flag = false
        @authors_array = @abstract.authors.pluck(:id)

        if @authors_array.include? current_user[:id]
            puts "\n+++++++ author included +++++++"
        end

        if current_user[:admin] == true
            @edit_flag = true
        end

        # == get author data from authors and abstract_authors
        sql = "SELECT authors.firstname, authors.lastname, abstract_authors.author_type FROM authors INNER JOIN abstract_authors ON authors.id = abstract_authors.author_id WHERE abstract_authors.abstract_id = '" + @abstract[:id].to_s + "';"
        @authors_data = ActiveRecord::Base.connection.execute(sql)

        corr_author = User.find(@abstract[:corr_author_id])
        @corr_author_name = corr_author[:firstname] + " " + corr_author[:lastname]
        pres_author = Author.find(@abstract[:pres_author_id])
        @pres_author_name = pres_author[:firstname] + " " + pres_author[:lastname]
        if @abstract[:reviewer1_id]
            reviewer1 = User.find(@abstract[:reviewer1_id])
            @reviewer1_name = reviewer1[:firstname] + " " + reviewer1[:lastname]
        else
            @reviewer1_name = "unassigned"
        end
        if @abstract[:reviewer1_id]
            reviewer2 = User.find(@abstract[:reviewer2_id])
            @reviewer2_name = reviewer2[:firstname] + " " + reviewer2[:lastname]
        else
            @reviewer2_name = "unassigned"
        end
        if @abstract[:present_id]
            present = Presentation.find(@abstract[:present_id])
            @present = present[:session_title]
        else
            @present = "unassigned"
        end
    end

    # ======= destroy =======
    def destroy
        @abstract.destroy
        respond_to do |format|
            format.html { redirect_to abstracts_url, notice: 'Abstract was successfully destroyed.' }
        end
    end

    private
        def set_abstract
            @abstract = Abstract.find(params[:id])
        end

        def update_params
            params.require(:abstract).permit(:id, :abs_title, :abs_text, :corr_author_id, :pres_author_id, :present_request, :keyword_1, :keyword_2, :keyword_3)
        end

        def filter_params
            params.permit(:keyword_1, :keyword_2, :keyword_3)
        end

        def rec_grade_params
            params.require(:abstract).permit(:which_reviewer, :abstract_ids => [], :reviewer_recs => [], :reviewer_grades => [])
        end

        def selection_params
            params.require(:abstract).permit(:abstract_id, :admin_final, :admin_finals => [], :abstract_ids => [])
        end

        def abstract_params
            ok_params = []
            ok_params << params.require(:abstract).permit(:corr_author_id, :pres_author_id, :reviewer1_id, :reviewer2_id, :presentation_id, :session_sequence, :abs_title, :abs_text, :keyword_1, :keyword_2, :keyword_3, :new_keyword_1, :new_keyword_2, :new_keyword_3, :present_request, :present_assigned, :reviewer1_rec, :reviewer2_rec, :accepted, :invited, :paper)
            ok_params << params.require(:author).permit(:firstnames => [], :lastnames => [])
            ok_params << params.require(:affiliation).permit(:institutions => [], :departments => [])
            ok_params << params.require(:abstract_author).permit(:author_types => [])
            return ok_params
        end
end
# corr_author_id, pres_author_id, reviewer1_id, reviewer2_id, presentation_id, session_sequence, abs_title, abs_text, keyword_1, keyword_2, keyword_3, present_request, present_assigned, reviewer1_rec, reviewer2_rec, accepted, invited, paper


# ======= ======= ======= users/select_reviewers.html.erb ======= ======= =======
# ======= ======= ======= users/select_reviewers.html.erb ======= ======= =======
# ======= ======= ======= users/select_reviewers.html.erb ======= ======= =======

<h2>Select Reviewers</h2>

<%= form_for("save_select", url: "/save_select", :html => {:id => "save_select"}) do %>

    <table>
        <thead>
            <tr>
                <th>name</th>
                <th>affiliation</th>
                <th>reviewer</th>
            </tr>
        </thead>
        <tbody>
            <% @users.each do |user| %>
                <% author = Author.where(:user_id => user[:id]).first %>
                <% affiliation = author.affiliation %>
                <% puts "affiliation: #{affiliation.inspect}" %>

                <tr>
                    <% fullname = user[:firstname].to_s + " " + user[:lastname].to_s  %>
                    <td class="main-col"><%= link_to fullname, user %></td>
                    <td><%= affiliation[:institution] + ", " + affiliation[:department] %></td>
                    <td></td>
                    <% if current_user.admin? %>
                        <% if user.reviewer? %>
                            <td>
                                <%= check_box_tag "user[reviewer_ids][]", user[:id], :checked %>
                            </td>
                        <% else %>
                            <td>
                                <%= check_box_tag "user[reviewer_ids][]", user[:id] %>
                            </td>
                        <% end %>
                    <% else %>
                        <% if user.reviewer? %>
                            <td>reviewer</td>
                        <% else %>
                            <td></td>
                        <% end %>
                    <% end %>
                </tr>
            <% end %>
            <tr>
                <td colspan="2"></td>
                <td><%= button_tag "submit" %></td>
            </tr>
        </tbody>
    </table>

<% end %>


# ======= ======= ======= users/assign_reviewers.html.erb ======= ======= =======
# ======= ======= ======= users/assign_reviewers.html.erb ======= ======= =======
# ======= ======= ======= users/assign_reviewers.html.erb ======= ======= =======

<h1>Assign Reviewers</h1>

<!-- ======= reviewers selectbox (users filtered for reviewer => true) ======= -->
<% reviewer_name_ids = [nil] %>
<% @reviewers.each_with_index do |reviewer, index| %>
    <% fullname = reviewer[:firstname] + " " + reviewer[:lastname] %>
    <% reviewer_name_ids << [fullname, reviewer[:id]] %>
<% end %>

<%= form_for("save_assign", url: "/save_assign", :html => {:id => "save_assign"}) do %>

    <%= fields_for :abstract do |a| %>

        <table class="abstractAdmin">
            <tr>
                <th>title</th>
                <th>primary</th>
                <th>reviewer1</th>
                <th>reviewer2</th>
                <th></th>
                <th>last update</th>
            </tr>

            <!-- ======= list abstracts/reviewers ======= -->
            <% @abstracts.each do |next_abstract| %>

                <!-- ======= reviewer initialize ======= -->
                <% selected_reviewer_id1 = nil %>
                <% selected_reviewer_id2 = nil %>
                <% if next_abstract[:reviewer1_id] %>
                    <% selected_reviewer_id1 = next_abstract[:reviewer1_id] %>
                <% end %>
                <% if next_abstract[:reviewer2_id] %>
                    <% selected_reviewer_id2 = next_abstract[:reviewer2_id] %>
                <% end %>

                <% sql = "SELECT authors.firstname, authors.lastname, abstract_authors.author_type FROM authors INNER JOIN abstract_authors ON authors.id = abstract_authors.author_id WHERE abstract_authors.abstract_id = '" + next_abstract[:id].to_s + "' AND abstract_authors.author_type = 'primary';" %>
                <% author_data = ActiveRecord::Base.connection.execute(sql) %>
                <% primary_author = author_data[0]["firstname"].to_s + " " + author_data[0]["lastname"].to_s %>

                <tr>
                    <td><%= link_to next_abstract[:abs_title], abstract_path(next_abstract) %></td>
                    <td><%= primary_author %></td>
                    <td><%= select_tag("abstract[reviewer1_ids][]", options_for_select(reviewer_name_ids, selected_reviewer_id1), :id => "abstract_reviewer1_ids_" + next_abstract[:id].to_s) %></td>
                    <td><%= select_tag("abstract[reviewer2_ids][]", options_for_select(reviewer_name_ids, selected_reviewer_id2), :id => "abstract_reviewer2_ids_" + next_abstract[:id].to_s) %></td>
                    <td>
                        <%= hidden_field_tag "abstract[abstract_ids][]", next_abstract[:id].to_s %>
                    </td>
                    <% formatted_date = next_abstract[:updated_at].in_time_zone("Eastern Time (US & Canada)").strftime('%a %b %d %l:%M') %>
                    <td>updated: <%= formatted_date %> </td>
                </tr>
            <% end %>

            <!-- ======= save all changes option ======= -->
            <tr>
                <td colspan="3"></td>
                <td colspan="3">
                    <button type="submit">Save all changes</button>
                </td>
            </tr>
        </table>
    <% end %>
<% end %>


# ======= ======= ======= abstracts/new.html.erb ======= ======= =======
# ======= ======= ======= abstracts/new.html.erb ======= ======= =======
# ======= ======= ======= abstracts/new.html.erb ======= ======= =======

<%= form_for(@abstract, url: "/signup_abstract") do |f| %>

    <!-- ======= reviewer initialize ======= -->
    <% selected_keyword1 = nil %>
    <% selected_keyword2 = nil %>
    <% selected_keyword3 = nil %>
    <% if @abstract[:keyword1_id] %>
        <% selected_keyword1 = @abstract[:keyword1_id] %>
    <% end %>
    <% if @abstract[:keyword2_id] %>
        <% selected_keyword2 = @abstract[:keyword2_id] %>
    <% end %>
    <% if @abstract[:keyword3_id] %>
        <% selected_keyword3 = @abstract[:keyword3_id] %>
    <% end %>

    <!-- ======= keywords selectboxes ======= -->
    <% keywords1 = [nil] %>
    <% @keywords1.each do |keyword1| %>
        <% keywords1 << [keyword1[:keyword_name], keyword1[:id]] %>
    <% end %>
    <% keywords2 = [nil] %>
    <% @keywords2.each do |keyword2| %>
        <% keywords2 << [keyword2[:keyword_name], keyword2[:id]] %>
    <% end %>
    <% keywords3 = [nil] %>
    <% @keywords3.each do |keyword3| %>
        <% keywords3 << [keyword3[:keyword_name], keyword3[:id]] %>
    <% end %>
    <% puts "keywords3: #{keywords3.inspect}" %>

    <!-- ======= reviewer initialize ======= -->
    <% selected_reviewer1 = nil %>
    <% selected_reviewer2 = nil %>
    <% if @abstract[:reviewer1_id] %>
        <% selected_reviewer1 = @abstract[:reviewer1_id] %>
    <% end %>
    <% if @abstract[:reviewer2_id] %>
        <% selected_reviewer2 = @abstract[:reviewer2_id] %>
    <% end %>

    <!-- ======= users selectbox ======= -->
    <% user_name_ids = [] %>
    <% @users.each_with_index do |user, index| %>
        <% fullname = user[:firstname] + " " + user[:lastname] %>
        <% user_name_ids << [fullname, user[:id]] %>
    <% end %>

    <!-- ======= entry screens ======= -->
    <div class="abstractEntryBox">

        <!-- ======= abstract ======= -->
        <%= fields_for :abstract do |abstract| %>
            <div class="abstractRow_1 toggle_input">
                <p class="abstractLabel_1">abstract title</p>
                <%= abstract.text_field :abs_title, placeholder: "Abstract Title", class: "title" %>
            </div>
            <div class="abstractRow_2 toggle_input">
                <p class="abstractLabel_2">abstract text</p>
                <%= abstract.text_area :abs_text, placeholder: "Abstract Text", class: "text", cols: "30", rows: "6" %>
            </div>

            <!-- ======= buttons ======= -->
            <div class="abstractRow_3 toggle_input">
                <button id="reviewBtn" class="abstractBtn" type="button">reviewers</button>
                <button id="nextBtn_1" class="abstractBtn" type="button">next</button>
            </div>
            <%= abstract.hidden_field :corr_author_id, value: current_user[:id].to_s %>
            <%= hidden_field_tag "admin_flag", @admin_flag.to_s %>
        <% end %>

        <!-- ======= authors ======= -->
        <div class="authorRow_1 toggle_input">
            <div id="primary" class="authorEntryGrp">
                <p class="authorLabel_1">primary author</p>
                <%= fields_for :author do |author| %>
                    <%= text_field_tag "author[firstnames][]", "Bill", id: "primary_firstname", class: "authorName entry firstname" %>
                    <%= text_field_tag "author[lastnames][]", "Clinton", id: "primary_lastname", class: "authorName entry lastname" %>
                <% end %>
                <%= fields_for :abstract_author do |abstract_author| %>
                    <%= hidden_field_tag "abstract_author[author_types][]", "primary", class: "author author_type" %>
                <% end %>
                <div class="radio">
                    <%= fields_for :abstract do |abstract| %>
                    <span><%= abstract.radio_button :pres_author_id, 0, class: "presenting" %></span>
                    <% end %>
                    <span>presenting</span>
                </div>
                <%= fields_for :affiliation do |affiliation| %>
                    <%= text_field_tag "affiliation[institutions][]", "Yale", id: "primary_institution", class: "affiliation entry institution" %>
                    <%= text_field_tag "affiliation[departments][]", "Law", id: "primary_department", class: "affiliation entry department" %>
                <% end %>
            </div>
            <p class="authorLabel_2">secondary authors</p>
        </div>
        <div id="authorRow_2" class="authorRow_2 toggle_input">
            <div id="secondary_" class="authorEntryGrp">
                <%= fields_for :author do |author| %>
                    <%= text_field_tag "author[firstnames][]", "George", id: "firstname_1", class: "authorName entry firstname" %>
                    <%= text_field_tag "author[lastnames][]", "Bush", id: "lastname_1", class: "authorName entry lastname" %>
                <% end %>
                <%= fields_for :abstract_author do |abstract_author| %>
                    <%= hidden_field_tag "abstract_author[author_types][]", "secondary", class: "author author_type" %>
                <% end %>
                <div class="radio">
                    <%= fields_for :abstract do |abstract| %>
                        <span><%= abstract.radio_button :pres_author_id, 1, class: "presenting" %></span>
                    <% end %>
                    <span>presenting</span>
                </div>
                <%= fields_for :affiliation do |affiliation| %>
                    <%= text_field_tag "affiliation[institutions][]", "Texas Tech", id: "primary_institution", class: " affiliation entry institution" %>
                    <%= text_field_tag "affiliation[departments][]", "Fratboyism", id: "primary_department", class: " affiliation entry department" %>
                <% end %>
            </div>
        </div>

        <!-- ======= buttons ======= -->
        <div class="authorRow_3 toggle_input">
            <button id="prevBtn_2" class="abstractBtn" type="button">prev</button>
            <button id="authorBtn" class="abstractBtn" type="button">add author</button>
            <button id="nextBtn_2" class="abstractBtn" type="button">next</button>
        </div>

        <!-- ======= keywords ======= -->
        <%= fields_for :abstract do |abstract| %>
            <div class="keyRow_1 toggle_input">
                <div id="primary" class="keyGrp_1">
                    <p class="keyLabel_1">
                        <span class="keywordLabel">keyword 1</span>
                        <span class="keywordLabel">keyword 2</span>
                        <span class="keywordLabel">keyword 3</span>
                    </p>
                </div>
                <p class="reviewerInfo">select 0 to 3 keywords</p>
                <%= abstract.select(:keyword_1, options_for_select(keywords1, selected_keyword1), {}, { :class => "keyword entry" }) %>
                <%= abstract.select(:keyword_2, options_for_select(keywords2, selected_keyword2), {}, { :class => "keyword entry" }) %>
                <%= abstract.select(:keyword_3, options_for_select(keywords3, selected_keyword3), {}, { :class => "keyword entry" }) %>
            </div>
            <div class="keyRow_2 toggle_input">
                <p class="reviewerInfo adminInfo">enter new keywords here</p>
                <%= text_field_tag "abstract[new_keyword_1]", "", id: "new_keyword_1", class: "keyword entry" %>
                <%= text_field_tag "abstract[new_keyword_2]", "", id: "new_keyword_2", class: "keyword entry" %>
                <%= text_field_tag "abstract[new_keyword_3]", "", id: "new_keyword_3", class: "keyword entry" %>
            </div>

            <!-- ======= buttons ======= -->
            <div class="keyRow_3 toggle_input">
                <button id="prevBtn_3" class="abstractBtn" type="button">prev</button>
                <button id="nextBtn_3" class="abstractBtn" type="button">next</button>
            </div>
        <% end %>

    </div>

<% end %>


# ======= ======= ======= abstracts/review_abstracts.html.erb ======= ======= =======
# ======= ======= ======= abstracts/review_abstracts.html.erb ======= ======= =======
# ======= ======= ======= abstracts/review_abstracts.html.erb ======= ======= =======

<% if @title %>
    <h1><%= @title %></h1>
<% else %>
    <h1>Review Abstract</h1>
<% end %>

<% grade_select_options = [nil, "A", "B", "C", "D", "F"] %>
<% rec_select_options = [nil, "oral", "poster", "rejected"] %>

<%= form_for("save_all_reviews", url: "/save_all_reviews", :html => {:id => "save_all_reviews"}) do |f| %>

    <table>
        <thead>
            <tr>
                <th>title</th>
                <th>corresponding author</th>
                <th>presenting author</th>
                <th>primary author</th>
                <th>recommendation</th>
                <th>grade</th>
            </tr>
        </thead>

        <tbody>


            <% whichReviewer = nil %>

            <!-- ======= loop through all abstracts ======= -->
            <% @abstracts.each do |abstract| %>
                <% puts "abstract[:reviewer1_rec]: #{abstract[:reviewer1_rec].inspect}" %>
                <% puts "abstract[:reviewer1_grade]: #{abstract[:reviewer1_grade].inspect}" %>

                <!-- == get primary author -->
                <% prim_author_id = nil %>
                <% prim_author_name = nil %>
                <% sql = "SELECT authors.id, authors.firstname, authors.lastname, abstract_authors.author_type FROM authors INNER JOIN abstract_authors ON authors.id = abstract_authors.author_id WHERE abstract_authors.abstract_id = '" + abstract[:id].to_s + "' AND abstract_authors.author_type = 'primary';" %>
                <% author_data = ActiveRecord::Base.connection.execute(sql) %>

                <% author_data.each do |author| %>
                    <% prim_author_name = author["firstname"] + " " + author["lastname"] %>
                    <% prim_author_id = author["id"] %>
                <% end %>

                <!-- ======= loop through reviewer abstracts ======= -->
                <% if User.exists?(abstract[:corr_author_id]) %>

                    <!-- == corresponding/presenting authors == -->
                    <% corr_author = User.find(abstract[:corr_author_id]) %>
                    <% corr_author_name = corr_author[:firstname].to_s + " " + corr_author[:lastname].to_s %>
                    <% pres_author = Author.find(abstract[:pres_author_id]) %>
                    <% pres_author_name = pres_author[:firstname].to_s + " " + pres_author[:lastname].to_s %>

                    <!-- ======= abstract row ======= -->
                    <tr>
                        <td class="main-col"><%= link_to abstract[:abs_title], abstract_path(abstract) %></td>
                        <td><%= link_to corr_author_name, user_path(abstract[:corr_author_id]) %></td>
                        <td><%= link_to pres_author_name, author_path(abstract[:pres_author_id]) %></td>
                        <td><%= link_to prim_author_name, author_path(prim_author_id.to_s) %></td>

                        <!-- == recommendations and grades -->
                        <% if current_user[:id] == abstract[:reviewer1_id] %>
                            <% whichReviewer = "reviewer1" %>
                            <td><%= select_tag("abstract[reviewer_recs][]", options_for_select(rec_select_options, abstract[:reviewer1_rec]), :id => "abstract_reviewer_rec_" + abstract[:id].to_s) %></td>

                            <td><%= select_tag("abstract[reviewer_grades][]", options_for_select(grade_select_options, abstract[:reviewer1_grade]), :id => "abstract_reviewer_grade_" + abstract[:id].to_s) %></td>
                        <% else %>
                            <% whichReviewer = "reviewer2" %>
                            <td><%= select_tag("abstract[reviewer_recs][]", options_for_select(rec_select_options, abstract[:reviewer2_rec]), :id => "abstract_reviewer_rec_" + abstract[:id].to_s) %></td>

                            <td><%= select_tag("abstract[reviewer_grades][]", options_for_select(grade_select_options, abstract[:reviewer2_grade]), :id => "abstract_reviewer_grade_" + abstract[:id].to_s) %></td>
                        <% end %>

                        <%= hidden_field_tag "abstract[abstract_ids][]", abstract[:id], :id => "abstract_abstract_ids_" + abstract[:id].to_s %>

                    </tr>
                <% end %>
            <% end %>

            <!-- ======= save all changes option ======= -->
            <tr>
                <td colspan="3"></td>
                <%= hidden_field_tag "abstract[which_reviewer]", whichReviewer %>
                <% puts "whichReviewer: #{whichReviewer}" %>
                <td colspan="3"><%= f.button "Save all changes", type: "submit" %></td>
            </tr>

        </tbody>
    </table>
<% end %>


# ======= ======= ======= abstracts/select_abstracts.html.erb ======= ======= =======
# ======= ======= ======= abstracts/select_abstracts.html.erb ======= ======= =======
# ======= ======= ======= abstracts/select_abstracts.html.erb ======= ======= =======

<h1>Select Abstracts</h1>

<!-- ======= users selectbox ======= -->
<% user_name_ids = [] %>
<% @users.each_with_index do |user, index| %>
    <% fullname = user[:firstname] + " " + user[:lastname] %>
    <% user_name_ids << [fullname, user[:id]] %>
<% end %>
<% keywords1 = [nil] %>
<% @keywords_1.each_with_index do |keyword, index| %>
    <% keywords1 << [keyword[:keyword_name], keyword[:id]] %>
<% end %>
<% keywords2 = [nil] %>
<% @keywords_2.each_with_index do |keyword, index| %>
    <% keywords2 << [keyword[:keyword_name], keyword[:id]] %>
<% end %>
<% keywords3 = [nil] %>
<% @keywords_3.each_with_index do |keyword, index| %>
    <% keywords3 << [keyword[:keyword_name], keyword[:id]] %>
<% end %>

<!-- ======= admin_select selectbox ======= -->
<% admin_select_options = [nil, "oral", "poster", "rejected"] %>

<!-- ======= filter by keyword ======= -->
<%= form_for("filter_by_keyword", url: "/filter_by_keyword", :html => {:id => "filter_by_keyword"}) do %>
    <div id="filters">
        <%= select_tag("keyword_1", options_for_select(keywords1), :id => "keywords1") %>
        <%= select_tag("keyword_2", options_for_select(keywords2), :id => "keywords2") %>
        <%= select_tag("keyword_3", options_for_select(keywords3), :id => "keywords3") %>
        <%= button_tag "Filter by Keyword", type: "submit", id: "filter_selections" %>
        <%= button_tag "Get all abstracts", type: "button", id: "all_selections" %>
    </div>
<% end %>

<%= form_for("save_selection", url: "/save_selection", :html => {:id => "save_selection"}) do %>
<!-- == note: form submitted via javascript -->

    <%= fields_for :abstract do |a| %>

        <!-- == for one-at-a-time abstract save (value via javascript) -->
        <%= a.hidden_field "abstract_id" %>
        <%= a.hidden_field "admin_final" %>

        <table class="abstractAdmin">
            <tr>
                <th>title</th>
                <th>primary</th>
                <th>reviewers</th>
                <th>recommendations</th>
                <th>grades</th>
                <th>final</th>
                <th></th>
            </tr>

            <!-- ======= list abstracts/reviewers ======= -->
            <% @abstracts.each do |next_abstract| %>

                <!-- == get reviewers via abstracgt reviewer ids== -->
                <% if next_abstract[:reviewer1_id] %>
                    <% selected_reviewer1 = User.find(next_abstract[:reviewer1_id]) %>
                    <% selected_reviewer_id1 = selected_reviewer1[:id] %>
                    <% reviewer1 = User.find(next_abstract[:reviewer1_id]) %>
                    <% reviewer_name1 = reviewer1[:firstname] + " " + reviewer1[:lastname]%>
                <% end %>
                <% if next_abstract[:reviewer2_id] %>
                    <% selected_reviewer2 = User.find(next_abstract[:reviewer2_id]) %>
                    <% selected_reviewer_id2 = selected_reviewer2[:id] %>
                    <% reviewer2 = User.find(next_abstract[:reviewer2_id]) %>
                    <% reviewer_name2 = reviewer2[:firstname] + " " + reviewer2[:lastname]%>
                <% end %>

                <!-- == get abstract authors via join table == -->
                <% sql = "SELECT authors.firstname, authors.lastname, abstract_authors.author_type FROM authors INNER JOIN abstract_authors ON authors.id = abstract_authors.author_id WHERE abstract_authors.abstract_id = '" + next_abstract[:id].to_s + "' AND abstract_authors.author_type = 'primary';" %>
                <% author_data = ActiveRecord::Base.connection.execute(sql) %>
                <% primary_author = author_data[0]["firstname"].to_s + " " + author_data[0]["lastname"].to_s %>

                <!-- ======= abstract identity/reviewer1 rec/grade ======= -->
                <tr>
                    <td><%= link_to next_abstract[:abs_title], abstract_path(next_abstract) %></td>
                    <td><%= primary_author %></td>
                    <td><%= reviewer_name1 %></td>
                    <td><%= next_abstract[:reviewer1_rec] %></td>
                    <td><%= next_abstract[:reviewer1_grade] %></td>
                    <td><%= select_tag("abstract[admin_finals][]", options_for_select(admin_select_options, next_abstract[:admin_final]), :id => "abstract_admin_finals_" + next_abstract[:id].to_s) %></td>
                    <td>
                        <%= hidden_field_tag "abstract[abstract_ids][]", next_abstract[:id].to_s %>
                    </td>
                    <% formatted_date = next_abstract[:updated_at].in_time_zone("Eastern Time (US & Canada)").strftime('%a %b %d %l:%M') %>
                    <td>updated: <%= formatted_date %> </td>
                </tr>

                <!-- ======= reviewer2 rec/grade ======= -->
                <tr>
                    <td></td>
                    <td></td>
                    <td><%= reviewer_name2 %></td>
                    <td><%= next_abstract[:reviewer2_rec] %></td>
                    <td><%= next_abstract[:reviewer2_grade] %></td>
                    <td></td>
                </tr>
                <tr>
                    <td colspan="6"></td>
                </tr>
            <% end %>

            <!-- ======= save all changes option ======= -->
            <tr>
                <td colspan="3"></td>
                <td colspan="3"><%= a.button "Save all changes", type: "button", id: "save_all_selections" %></td>
            </tr>
        </table>
    <% end %>
<% end %>


# ======= ======= ======= script.js ======= ======= =======
# ======= ======= ======= script.js ======= ======= =======
# ======= ======= ======= script.js ======= ======= =======

$(document).on('turbolinks:load', function() {
    console.log("== turbolinks:load ==");

    // ======= check pathname =======
    var pathname = window.location.pathname;
    console.log("pathname:", pathname);

    // ======= window conditionals =======
    if (pathname == "/assign_reviewers") {
        console.log("PATHNAME: /assign_reviewers");
        activateSubmitReviewers();
    } else if ((pathname == "/select_abstracts") || (pathname == "/filter_by_keyword")) {
        console.log("PATHNAME: /select_abstracts");
        activateSubmitSelection();
    } else {
        // initAutoComplete();
    }

    // ======= activateSubmitSelection =======
    function activateSubmitSelection() {
        console.log("== activateSubmitSelection ==");
        $('.submit_selection').on('click', submitSelection);
        $('#save_all_selections').on('click', submitAllSelections);
        $('#all_selections').on('click', getAllAbstracts);
    }

    // ======= getAllAbstracts =======
    function getAllAbstracts() {
        console.log("== getAllAbstracts ==");
        location.href = "/select_abstracts";
    }

    // ======= activateSubmitReviewers =======
    function activateSubmitReviewers() {
        console.log("== activateSubmitReviewers ==");
        $('.submit_reviewers').on('click', submitReviewers);
        $('#save_all_reviewers').on('click', submitAllReviewers);
    }

    // ======= submitSelection =======
    function submitSelection(e) {
        console.log("== submitSelection ==");
        e.preventDefault();
        var abstract_id = (e.currentTarget.id).split("_")[2];
        var admin_final = $('#abstract_admin_finals_' + abstract_id).val();
        $("#abstract_abstract_id").val(abstract_id);
        $("#abstract_admin_final").val(admin_final);
        $("#save_selection").submit();
    }

    // ======= submitReviewers =======
    function submitReviewers(e) {
        console.log("== submitReviewers ==");
        e.preventDefault();
        var abstract_id = (e.currentTarget.id).split("_")[2];
        var reviewer1_id = $('#abstract_reviewer1_ids_' + abstract_id).val();
        var reviewer2_id = $('#abstract_reviewer2_ids_' + abstract_id).val();
        console.log("abstract_id:", abstract_id);
        console.log("reviewer1_id:", reviewer1_id);
        console.log("reviewer2_id:", reviewer2_id);
        $("#abstract_reviewer1_id").val(reviewer1_id);
        $("#abstract_reviewer2_id").val(reviewer2_id);
        $("#abstract_abstract_id").val(abstract_id);
        $("#save_reviewers").submit();
    }

    // ======= submitAllSelections =======
    function submitAllSelections(e) {
        console.log("== submitAllSelections ==");
        e.preventDefault();
        $("#abstract_abstract_id").val("all");
        console.log("abstract_abstract_id", $("#abstract_abstract_id").val());
        $("#save_selection").submit();
    }

    // ======= submitAllReviewers =======
    function submitAllReviewers(e) {
        console.log("== submitAllReviewers ==");
        e.preventDefault();
        $("#abstract_abstract_id").val("all");
        console.log("abstract_abstract_id", $("#abstract_abstract_id").val());
        $("#save_reviewers").submit();
    }

    var abstractMgr = {
        secondaryAuthorIndex: 1,
        currentInputsIndex: 0,
        firstnames: null,
        lastnames: null,
        institutions: null,
        departments: null,
        author_types: null,

        // ======= initialize =======
        initialize: function() {
            console.log("== initialize ==");
            $('.abstractRow_1').css('display', 'block');
            $('.abstractRow_2').css('display', 'block');
            $('.abstractRow_3').css('display', 'block');
            $('#prevBtn').on('click', abstractMgr.prevInputView);
            $('#nextBtn_1').on('click', abstractMgr.nextInputView);
        },

        // ======= addNewAuthor =======
        addNewAuthor: function(e) {
            console.log("== addNewAuthor ==");
            e.preventDefault();
            abstractMgr.secondaryAuthorIndex = abstractMgr.secondaryAuthorIndex + 1;
            var authorIndex = abstractMgr.secondaryAuthorIndex;
            var authorHtml = "";
            authorHtml += "<div id='secondary_" + authorIndex + "' class='authorEntryGrp'>";

            // == author names inputs
            authorHtml += "<input type='text' name='author[firstnames][]' id='firstname_" + authorIndex + "' value='George' class='authorName entry firstname'>";
            authorHtml += "<input type='text' name='author[lastnames][]' id='lastname_" + authorIndex + "' value='Bush' class='authorName entry lastname'>";

            // == author type
            authorHtml += "<input type='hidden' name='abstract_author[author_types][]' id='abstract_author_author_types_' value='secondary' class='author author_type'>"

            // == presenting radios
            authorHtml += "<div class='radio'>";
            authorHtml += "<span><input class='presenting' type='radio' value='" + authorIndex + "' name='abstract[pres_author_id]' id='abstract_pres_author_id_true'></span>";
            authorHtml += "<span>presenting</span>";
            authorHtml += "</div>";

            // == affiliations
            authorHtml += "<input type='text' name='affiliation[institutions][]' id='sec_institution_" + authorIndex + "' value='Texas Tech' class='affiliation entry institution'>";
            authorHtml += "<input type='text' name='affiliation[departments][]' id='sec_department_" + authorIndex + "' value='Fratboyism' class='affiliation entry department'>";
            authorHtml += "</div>";
            $('#authorRow_2').append(authorHtml);
        },

        // ======= submitAbstractForm =======
        submitAbstractForm: function() {
            console.log("== submitAbstractForm ==");
            $("#new_abstract").submit();
        },

        // ======= prevInputView =======
        prevInputView: function(e) {
            // console.log("== prevInputView ==");
            abstractMgr.toggleInputView(-1);
            e.preventDefault();
        },

        // ======= nextInputView =======
        nextInputView: function(e) {
            // console.log("== nextInputView ==");
            abstractMgr.toggleInputView(1);
            e.preventDefault();
        },

        // ======= toggleInputView =======
        toggleInputView: function(inc_dec) {
            console.log("== toggleInputView ==");

            var index = abstractMgr.currentInputsIndex;
            var adminFlag = $('#admin_flag').val();
            console.log("adminFlag:", adminFlag);

            // == increase or decrease index
            index += inc_dec;
            if (index < 0) {
                index = 3;
            } else if (index >= 4) {
                index = 0;
            }
            console.log("index:", index);

            if (index == 0) {
                $('.reviewRow_1').css('display', 'none');
                $('.reviewRow_2').css('display', 'none');
                $('.reviewRow_3').css('display', 'none');
                $('.reviewRow_4').css('display', 'none');
                $('.abstractRow_1').css('display', 'block');
                $('.abstractRow_2').css('display', 'block');
                $('.abstractRow_3').css('display', 'block');
                $('.authorRow_1').css('display', 'none');
                $('.authorRow_2').css('display', 'none');
                $('.authorRow_3').css('display', 'none');
                $('#nextBtn_1').on('click', abstractMgr.nextInputView);
                $('#nextBtn_2').off('click', abstractMgr.nextInputView);
                $('#nextBtn_3').off('click', abstractMgr.nextInputView);
                $('#authorBtn').off('click', abstractMgr.addNewAuthor);
            }
            if (index == 1) {
                $('.abstractRow_1').css('display', 'none');
                $('.abstractRow_2').css('display', 'none');
                $('.abstractRow_3').css('display', 'none');
                $('.authorRow_1').css('display', 'block');
                $('.authorRow_2').css('display', 'block');
                $('.authorRow_3').css('display', 'block');
                $('.keyRow_1').css('display', 'none');
                $('.keyRow_2').css('display', 'none');
                $('.keyRow_3').css('display', 'none');
                $('#prevBtn_2').on('click', abstractMgr.prevInputView);
                $('#prevBtn_3').off('click', abstractMgr.prevInputView);
                $('#nextBtn_1').off('click', abstractMgr.nextInputView);
                $('#nextBtn_2').on('click', abstractMgr.nextInputView);
                $('#nextBtn_3').off('click', abstractMgr.nextInputView);
                $('#authorBtn').on('click', abstractMgr.addNewAuthor);
            }
            if (index == 2) {
                $('.authorRow_1').css('display', 'none');
                $('.authorRow_2').css('display', 'none');
                $('.authorRow_3').css('display', 'none');
                $('.keyRow_1').css('display', 'block');
                $('.keyRow_2').css('display', 'block');
                if (adminFlag == "true") {
                    $('.adminInfo').css('display', 'block');
                    $('#abstract_keyword_1').css('display', 'block');
                    $('#abstract_keyword_2').css('display', 'block');
                    $('#abstract_keyword_3').css('display', 'block');
                } else {
                    $('.adminInfo').css('display', 'none');
                    $('#new_keyword_1').css('display', 'none');
                    $('#new_keyword_2').css('display', 'none');
                    $('#new_keyword_3').css('display', 'none');
                }
                $('.keyRow_3').css('display', 'block');
                $('.reviewRow_1').css('display', 'none');
                $('.reviewRow_2').css('display', 'none');
                $('.reviewRow_3').css('display', 'none');
                $('.reviewRow_4').css('display', 'none');

                var firstnames = $('.firstname').map(function(){return $(this).val();}).get();
                var lastnames = $('.lastname').map(function(){return $(this).val();}).get();
                var institutions = $('.institution').map(function(){return $(this).val();}).get();
                var departments = $('.department').map(function(){return $(this).val();}).get();
                var author_types = $('.author_type').map(function(){return $(this).val();}).get();

                var presentingRadios = $('.presenting')
                var checkedRadio = $('.presenting:checked', '#new_abstract').val()

                abstractMgr.firstnames = firstnames;
                abstractMgr.lastnames = lastnames;
                abstractMgr.institutions = institutions;
                abstractMgr.departments = departments;
                abstractMgr.author_types = author_types;

                $('#prevBtn_2').off('click', abstractMgr.prevInputView);
                $('#prevBtn_3').on('click', abstractMgr.prevInputView);
                $('#nextBtn_1').off('click', abstractMgr.nextInputView);
                $('#nextBtn_2').off('click', abstractMgr.nextInputView);
                $('#nextBtn_3').on('click', abstractMgr.nextInputView);
                $('#authorBtn').off('click', abstractMgr.addNewAuthor);
            }
            if (index == 3) {
                $('.keyRow_1').css('display', 'none');
                $('.keyRow_2').css('display', 'none');
                $('.keyRow_3').css('display', 'none');
                $('#secondary_authors').append(abstractMgr.firstnames);
                $('#secondary_authors').append(abstractMgr.lastnames);
                $('#secondary_authors').append(abstractMgr.institutions);
                $('#secondary_authors').append(abstractMgr.departments);
                $('#secondary_authors').append(abstractMgr.author_types);
                $('#nextBtn_3').text('submit');
                $("#new_abstract").submit();
            }

            // == update master index
            abstractMgr.currentInputsIndex = index;
        }
    }
    abstractMgr.initialize()
});
