<%# sessions << [session[:session_title] + " / " + session_org_name, session[:id]] %>

<%= hidden_field_tag "abstract[keywords_ng][]", abstract[:id].to_s %>

<input id="keywordCheck_<%= abstract[:id].to_s %>" class="keywordCheck" type="checkbox" value="<%= abstract[:id].to_s %>" name="abstract[keywords_ok][]" <%= keyword_check %>>

<div class="invitedCheckBox">
    <span>
        <input id="invitedCheck" class="checkEntry" type="checkbox" name="abstract[invited]">
        <i>check if invited</i>
    </span>
    <span>
        <%= abstract.select(:presentation_id, options_for_select(sessions), {}, { :class => "sessionSelect" }) %>
        <i></i>
    </span>
</div>

<div class="invitedCheckBox">
    <span>
        <input id="invitedCheck" class="checkEntry" type="checkbox" name="abstract[invited]">
        <i>check if invited</i>
    </span>
    <span>
        <%= abstract.select(:presentation_id, options_for_select(sessions), {}, { :class => "selectEntry sessionSelect" }) %>
    </span>
</div>
<div class="sessionSelectBox">
    <span>
        <%= abstract.select(:presentation_id, options_for_select(sessions), {}, { :class => "selectEntry sessionSelect" }) %>
    </span>
</div>

<%= f.text_area "abstract[abs_comment]", "", maxlength: "2500", placeholder: "Add comment text", class: "commentEntry leftEntry", cols: "30", rows: "4" %>

<% @authors_data_array.each_with_index do |author, index| %>
    <div class="authors">
        <span class="authorInfo"><%= author["firstname"] %></span>
        <span class="authorInfo"><%= author["lastname"] %></span>
        <span class="authorInfo"><%= author["institution"] %></span>
        /
        <span class="authorInfo"><%= author["department"] %></span>
        <%= fields_for :author do |auth| %>
            <span><%= check_box_tag "author[delete_authors][]", author["id"] %></span>
            <i>check to delete author</i>
        <% end %>
    </div>
<% end %>

<% if object.errors.any? %>
    <% puts "+++ object.errors.any? +++" %>
    <div id="error_explanation">
        <% puts "+++ error_explanation +++" %>
        <div class="alert alert-danger alert-dismissable">
            <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
            <p><strong>This form contains <%= pluralize(object.errors.count, 'error') %>.</strong></p>
            <ul>
                <% object.errors.full_messages.each do |msg| %>
                    <li><%= msg %></li>
                <% end %>
            </ul>
        </div>
    </div>
<% end %>

<%= devise_error_messages! %>

.menuItem, .menuClick {
    display: block;
    height: 20px;
    width: 90%;
    margin: 10px;
    margin-left: 10%;
    padding-top: 5px;
    text-align: center;
    text-decoration: none;
    font-size: 0.9em;
    color: white;
    border-radius: 4px;
    -webkit-box-shadow: 3px 3px 3px #999;
	-moz-box-shadow: 3px 3px 3px #999;
	box-shadow: 3px 3px 3px #999;
}
.menuClick {
    -webkit-box-shadow: none;
	-moz-box-shadow: none;
	box-shadow: none;
}


// ======= toggleShadow =======
function toggleShadow(e) {
    console.log("== toggleShadow ==");
    console.log("e.currentTarget.id:", e.currentTarget.id);
    e.preventDefault();
    if ($('#' + e.currentTarget.id).hasClass('menuClick')) {
        $('#' + e.currentTarget.id).removeClass('menuClick');
    } else {
        $('#' + e.currentTarget.id).addClass('menuClick');
    }
}

// ======= activateButtonClicks =======
function activateButtonClicks() {
    console.log("== activateButtonClicks ==");
    // $('.menuItem').on('mousedown', toggleShadow);
    // $('.menuItem').on('mouseup', toggleShadow);
}



<div class="dataRow">
    <div class="formLabel">institution</div>
    <div class="formValue">
        <%= text_field_tag :institution, @author_data["institution"], class: "authorName entry institution" %></span>
    </div>
</div>
<div class="dataRow">
    <div class="formLabel">department</div>
    <div class="formValue">
        <%= text_field_tag :department, @author_data["department"], class: "authorName entry department" %></span>
    </div>
</div>



======= ======= ======= ======= ======= ======= =======
======= ======= ======= ======= ======= ======= =======
======= ======= ======= ======= ======= ======= =======

<!-- ======= primary author ======= -->
<div class="dataRow aR_2 toggle_input authorRow_2">
    <p class="dataLabel">primary author</p>
    <%= fields_for :author do |author| %>
        <%= text_field_tag "author[firstnames][]", "Bill", id: "primary_firstname", class: "dataEntry leftEntry", placeholder: "first name" %>
        <%= text_field_tag "author[lastnames][]", "Clinton", id: "primary_lastname", class: "dataEntry", placeholder: "last name" %>
    <% end %>
    <%= fields_for :abstract_author do |abstract_author| %>
        <%= hidden_field_tag "abstract_author[author_types][]", "primary", class: "author author_type" %>
    <% end %>
    <%= fields_for :abstract do |abstract| %>
        <%= abstract.radio_button :pres_author_id, 0, class: "presenting" %>
    <% end %>
    <i class="radioLabel">presenting</i>
    <%= fields_for :affiliation do |affiliation| %>
        <%= text_field_tag "affiliation[institutions][]", "Yale University", id: "primary_institution", class: "dataEntry leftEntry", placeholder: "institution" %>
        <%= text_field_tag "affiliation[departments][]", "Law", id: "primary_department", class: "dataEntry", placeholder: "department" %>
    <% end %>
</div>

<!-- ======= secondary authors ======= -->
<div class="dataRow aR_3 toggle_input authorRow_3">
    <p class="dataLabel">secondary authors</p>
    <div class="scrollBox">
        <div id='secondary_1'>
            <%= fields_for :author do |author| %>
                <%= text_field_tag "author[firstnames][]", "George", id: "firstname_1", class: "dataEntry secAuthor", placeholder: "firstname" %>
                <%= text_field_tag "author[lastnames][]", "Bush", id: "lastname_1", class: "dataEntry secAuthor", placeholder: "lastname" %>
            <% end %>
            <%= fields_for :abstract_author do |abstract_author| %>
                <%= hidden_field_tag "abstract_author[author_types][]", "secondary", class: "author author_type" %>
            <% end %>
            <%= fields_for :abstract do |abstract| %>
                <%= abstract.radio_button :pres_author_id, 1, class: "presenting" %>
            <% end %>
            <i class="radioLabel">presenting</i>
            <%= fields_for :affiliation do |affiliation| %>
                <%= text_field_tag "affiliation[institutions][]", "University of Texas", class: "dataEntry leftEntry secAuthor", placeholder: "institution" %>
                <%= text_field_tag "affiliation[departments][]", "Business", class: "dataEntry secAuthor lastDept", placeholder: "department" %>
            <% end %>
        </div>
    </div>
</div>

======= ======= ======= ======= ======= ======= =======
======= ======= ======= ======= ======= ======= =======
======= ======= ======= ======= ======= ======= =======



<!-- == dataBox == -->
<div id="dataBox">
    <h2 class="dataTitle">Welcome to the <span>ForestSat 2018</span> Abstract Submission Tool</h2>
    <p class="dataText">
        To submit an abstract:
        <ul class="dataInfo">
            <li><span>register</span> as a new User</li>
            <li><span>reply</span> to confirmation email</li>
            <li><span>log In</span> to your new account</li>
            <li><span>submit</span> your abstract</li>
        </ul>
    </p>
    <p class="dataText">
        Upon successfully submitting your abstract, an email confirmation will be sent
    </p>
</div>

#bgBanner {
    position: fixed;
    top: 0;
    left: 0;
    /*background-color: red;*/
    background: url(forest_banner.jpg);
    background-repeat: no-repeat;
    /*background-size: 300px 152px;*/
    margin: 0;
    /*width: 100%;
    height: 152px;*/
    z-index: -1;
    /*background size: 100% 700px;*/
    /*height: 152;
    width: 100%;*/
}


<!-- == get corresponding/presenting authors -->
<% if User.exists?(abstract_data[:corr_author_id]) %>
    <% corr_author = User.find(abstract_data[:corr_author_id]) %>
    <% corr_author_name = corr_author.full_name %>
    <% pres_author = Author.find(abstract_data[:pres_author_id]) %>
    <% pres_author_name = pres_author.full_name %>

    <!-- == get primary author -->
    <% primary_author_id = nil %>
    <% primary_author_name = nil %>
    <% sql = "SELECT authors.id,
        authors.firstname,
        authors.lastname,
        abstract_authors.author_type,
        affiliations.institution,
        affiliations.department
    FROM authors
    INNER JOIN abstract_authors
        on authors.id = abstract_authors.author_id
    INNER JOIN author_affiliations
        on authors.id = author_affiliations.author_id
    INNER JOIN affiliations
        on affiliations.id = author_affiliations.affiliation_id
        WHERE abstract_authors.abstract_id = '" + abstract_data[:id].to_s + "'
        AND abstract_authors.author_type = 'primary';" %>
    <% primary_author = ActiveRecord::Base.connection.execute(sql) %>
    <% primary_author.each do |author| %>
        <% primary_author_name = author["firstname"] + " " + author["lastname"] + " (" + author["institution"] + " - " + author["department"] + ")" %>
        <% primary_author_id = author["id"] %>
    <% end %>

    <!-- == get secondary authors -->
    <% sql = "SELECT authors.id,
        authors.firstname,
        authors.lastname,
        abstract_authors.author_type,
        affiliations.institution,
        affiliations.department
    FROM authors
    INNER JOIN abstract_authors
        on authors.id = abstract_authors.author_id
    INNER JOIN author_affiliations
        on authors.id = author_affiliations.author_id
    INNER JOIN affiliations
        on affiliations.id = author_affiliations.affiliation_id
        WHERE abstract_authors.abstract_id = '" + abstract_data[:id].to_s + "'
        AND abstract_authors.author_type = 'secondary';" %>
    <% sec_authors = ActiveRecord::Base.connection.execute(sql) %>
    <% sec_authors_array = sec_authors.to_a %>
    <% puts "sec_authors_array: #{sec_authors_array.inspect}" %>

    <tr class="abstractTitle">
        <td><%= abstract_data[:id] %></td>
        <td class="titleCell"><%= link_to abstract_data[:abs_title], abstract_path(abstract_data) %></td>
        <% if current_user[:id] == abstract_data[:corr_author_id] || current_user[:admin] == true %>
            <td class="adminHead" colspan="2"><%= "edit/delete" %></td>
        <% else %>
            <td></td>
            <td></td>
        <% end %>
    </tr>
    <tr class="abstractAuthors">
        <td></td>
        <td class="authorCell">
            <span class="mainAuthLabel">presenting: </span>
            <span><%= link_to pres_author_name, author_path(abstract_data[:pres_author_id]) %>  </span>
            <span class="mainAuthLabel">primary: </span>
            <span><%= link_to primary_author_name, author_path(primary_author_id) %>  </span>
        </td>
        <!-- == allow corresponding authors/admins to edit/delete (only) -->
        <% if current_user[:id] == abstract_data[:corr_author_id] || current_user[:admin] == true %>
            <td class="adminCell"><%= link_to 'E', edit_abstract_path(abstract_data) %></td>
            <td class="adminCell"><%= link_to 'D', abstract_data, method: :delete, data: { confirm: 'Are you sure?' } %></td>
        <% else %>
            <td></td>
            <td></td>
        <% end %>
    </tr>
    <tr class="abstractAuthors">
        <td></td>
        <td class="authorCell">
            <span class="mainAuthLabel">authors: </span>
            <span class="secAuthLabel">
            <% sec_authors_array.each_with_index do |author, index| %>
                    <% if index < (sec_authors_array.length - 1) %>
                        <%= author["firstname"] + " " + author["lastname"] %>
                        <i><%= " (" + author["institution"] + " - " + author["department"] + "), " %></i>
                    <% else %>
                        <%= author["firstname"] + " " + author["lastname"] %>
                        <i><%= " ("+ author["institution"] + " - " + author["department"] + ") " %></i>
                    <% end %>
            <% end %>
        </span>
        </td>
        <td></td>
        <td></td>
    </tr>
    <tr class="tableSpacer"><td colspan="4"></td></tr>
<% end %>


<% if i == 0 %>
    <span class="primaryAuthor">
        <%= author['name'] %>
    </span>
    <span>
        <%= " (" %>
        <% author['affls'].each_with_index do |affiliation, j| %>
            <% if j == author['affls'].length %>
                <%= affiliation['institution'] + " - " + affiliation['department'] + ")" %>
            <% else %>
                <%= affiliation['institution'] + " - " + affiliation['department'] + ", " %>
            <% end %>
        <% end %>
    </span>
<% else %>
    <span>
        <%= ", " %>
        <span>
            <%= author['name'] %>
        </span>
        <span>
            <%= " (" %>
            <% author['affls'].each_with_index do |affiliation, k| %>
                <% if k == author['affls'].length %>
                    <%= affiliation['institution'] + " - " + affiliation['department'] + ")" %>
                <% else %>
                    <%= affiliation['institution'] + " - " + affiliation['department'] + ", " %>
                <% end %>
            <% end %>
        </span>
<% end %>


<%= hidden_field_tag "author[corr_firstname]", current_user[:firstname], id: "firstname_0" %>
<%= hidden_field_tag "author[corr_lastname]", current_user[:lastname], id: "lastname_0" %>
<span><%= abstract_author.radio_button :corr_author_type, 0, class: "presenting" %></span>
<span>primary</span>
<span><%= abstract_author.radio_button :corr_author_type, 1, class: "presenting" %></span>
<span>secondary</span>
<%= hidden_field_tag "author[corr_institution]", current_user[:institution], id: "institution_0" %>
<%= hidden_field_tag "author[corr_department]", current_user[:department], id: "department_0" %>


<% user_types_array = YAML::load(user_types) %>
<% puts "user_types_array: #{user_types_array.inspect}" %>

<% if current_user.reviewer? %>
    <td>
        <%= check_box_tag "user[reviewer_ids][]", user[:id], :checked %>
    </td>
<% else %>
    <td>
        <%= check_box_tag "user[reviewer_ids][]", user[:id] %>
    </td>
<% end %>


<!-- ======= reviews ======= -->
<div class="reviewRow_1 toggle_input">
    <div id="primary" class="reviewGrp_1">
        <p class="reviewLabel">
            <span>reviewer 1</span>
        </p>
        <p class="reviewLabel">
            <span>reviewer 2</span>
        </p>
    </div>
    <p class="reviewerInfo">enter new reviewer names here, or...</p>
    <input type="text" id="review_fname_1" class="reviewEntry">
    <input type="text" id="review_lname_1" class="reviewEntry">
    <input type="text" id="review_fname_2" class="reviewEntry">
    <input type="text" id="review_lname_2" class="reviewEntry">
</div>
<div class="reviewRow_2 toggle_input">
    <p class="reviewerInfo">...select from existing reviewers</p>
    <select id="reviewSelect_1" class="reviewSelect">
        <option value="">review1</option>
        <option value="">review2</option>
        <option value="">review3</option>
    </select>
    <select id="reviewSelect_2" class="reviewSelect">
        <option value="">review1</option>
        <option value="">review2</option>
        <option value="">review3</option>
    </select>
</div>
<div class="reviewRow_3 toggle_input">
    <p class="reviewLabel">
        <span>recommendation 1</span>
    </p>
    <p class="reviewLabel">
        <span>recommendation 2</span>
    </p>
    <div class="reviewRadio">
        <span>recommend</span>
        <span><input type="radio" name="reviewer_1" value="yes" id="recommend_"></span>
    </div>
    <div class="reviewRadio">
        <span>decline</span>
        <span><input type="radio" name="reviewer_1" value="no" id="decline_"></span>
    </div>
    <div class="reviewRadio">
        <span>recommend</span>
        <span><input type="radio" name="reviewer_2" value="yes" id="recommend_"></span>
    </div>
    <div class="reviewRadio">
        <span>decline</span>
        <span><input type="radio" name="reviewer_2" value="no" id="decline_"></span>
    </div>
</div>
<div class="reviewRow_4 toggle_input">
    <div id="buttonBar">
        <button id="prevBtn_4" class="abstractBtn">prev</button>
        <button id="nextBtn_4" class="abstractBtn">save abstract</button>
    </div>
</div>


<div id="menuBox">
    <div class="menuRow">
        <div id="signinItems" class="menuGroup">
            <p class="menuLabel">signin</p>
            <a href="#" id="home" class="menuItem">home</a>
            <a href="#" id="signup" class="menuItem">signup</a>
            <a href="#" id="signin" class="menuItem">signin</a>
        </div>
        <h1 id="mainTitle">ForestSat</h1>
    </div>
    <div class="menuRow">
        <div id="userItems" class="menuGroup">
            <p class="menuLabel">users</p>
            <a href="#" id="profile" class="menuItem">profile</a>
            <a href="#" id="all_users" class="menuItem">all users</a>
        </div>
        <div id="abstractItems" class="menuGroup">
            <p class="menuLabel">abstracts</p>
            <a href="#" id="my_abstracts" class="menuItem">my abstracts</a>
            <a href="#" id="all_abstracts" class="menuItem">all abstracts</a>
            <a href="#" id="new_abstract" class="menuItem">new abstract</a>
        </div>
    </div>
    <div class="menuRow">
        <div id="affItems" class="menuGroup">
            <p class="menuLabel">affiliations</p>
            <a href="#" id="all_affiliations" class="menuItem">all</a>
            <a href="#" id="new_affiliation" class="menuItem">new</a>
        </div>
        <div id="sessionItems" class="menuGroup">
            <p class="menuLabel">sessions</p>
            <a href="#" id="all_sessions" class="menuItem">all</a>
            <a href="#" id="new_session" class="menuItem">new</a>
        </div>
        <div id="roomItems" class="menuGroup">
            <p class="menuLabel">rooms</p>
            <a href="#" id="all_rooms" class="menuItem">all</a>
            <a href="#" id="new_room" class="menuItem">new</a>
        </div>
    </div>
</div>


<div id="secondary_" class="authorEntryGrp">
    <input type="text" id="firstname" class="authorName entry" placeholder="first name">
    <input type="text" id="lastname" class="authorName entry">
    <div class="radio">
        <span><input type="radio" name="prsenting" id="presenting_"></span>
        <span>presenting</span>
    </div>
    <input type="text" id="institution" class="affiliation entry">
    <input type="text" id="department" class="affiliation entry">
</div>
<div id="secondary_" class="authorEntryGrp">
    <input type="text" id="firstname" class="authorName entry" placeholder="first name">
    <input type="text" id="lastname" class="authorName entry">
    <div class="radio">
        <span><input type="radio" name="prsenting" id="presenting_"></span>
        <span>presenting</span>
    </div>
    <input type="text" id="institution" class="affiliation entry">
    <input type="text" id="department" class="affiliation entry">
</div>
<div id="secondary_" class="authorEntryGrp">
    <input type="text" id="firstname" class="authorName entry" placeholder="first name">
    <input type="text" id="lastname" class="authorName entry">
    <div class="radio">
        <span><input type="radio" name="prsenting" id="presenting_"></span>
        <span>presenting</span>
    </div>
    <input type="text" id="institution" class="affiliation entry">
    <input type="text" id="department" class="affiliation entry">
</div>
<div id="secondary_" class="authorEntryGrp">
    <input type="text" id="firstname" class="authorName entry" placeholder="first name">
    <input type="text" id="lastname" class="authorName entry">
    <div class="radio">
        <span><input type="radio" name="prsenting" id="presenting_"></span>
        <span>presenting</span>
    </div>
    <input type="text" id="institution" class="affiliation entry">
    <input type="text" id="department" class="affiliation entry">
</div>


<div id="header" class="section">
    <h1>ForestSat</h1>
    <div id="menuBox">
        <%= link_to "Home", home_path %> |
        <% if !current_user %>
            <%= link_to "Sign up", new_user_registration_path %> |
            <%= link_to "Sign in", new_user_session_path %>
        <% else %>
            <%= link_to "Sign out", destroy_user_session_path, :method => :delete %>
            <div class="menuLine">
                <%= link_to "Profile", user_path(current_user) %> |
                <%= link_to 'All Users', users_path %>
            </div>
            <div class="menuLine">
                <%= link_to "My Abstracts", "/my_abstracts" %> |
                <%= link_to "All Abstracts", abstracts_path %> |
                <%= link_to "New Abstract", new_abstract_path %>
            </div>
            <% if current_user.admin? %>
                <div class="menuLine">
                    <%= link_to "All Affiliations", affiliations_path %> |
                    <%= link_to "New Affiliation", new_affiliation_path %> -- --
                    <%= link_to "All Presentations", presentations_path %> |
                    <%= link_to "New Presentation", new_presentation_path %> -- --
                    <%= link_to "All Rooms", rooms_path %> |
                    <%= link_to "New Room", new_room_path %>
                </div>
            <% end %>
            Current User: <%= current_user[:firstname] %>
        <% end %>

    </div>
</div>


<%= fields_for :author do |author| %>
    <%= text_field_tag "author[firstnames][]", "George", id: "firstname_", class: "toggle_input author" %>
    <%= text_field_tag "author[lastnames][]", "Bush", id: "lastname_", class: "toggle_input author" %>
<% end %>
<%= fields_for :abstract_author do |abstract_author| %>
    <%= text_field_tag "abstract_author[author_types][]", "secondary", id: "author_types_", class: "toggle_input author" %>
<% end %>
<%= fields_for :affiliation do |affiliation| %>
    <%= affiliation.text_field :institution, value: "Cornell University", class: "toggle_input author" %>
    <%= affiliation.text_field :department, value: "Geology", class: "toggle_input author" %>
<% end %>


<% if abstracts_primary.length > 0 %>
    <p><span class="field-label">primary author:</span>
    <% abstracts_primary.each do |abstract| %>
        <span><%= abstract[:abstract_title] %></span>
    <% end %>
    </p>
<% end %>

<% if abstracts_secondary.length > 0 %>
    <span class="field-label">secondary author:</span>
    <% abstracts_secondary.each do |abstract| %>
        <span><%= abstract[:abstract_title] %></span>
    <% end %>
    </p>
<% end %>

<% if abstracts_presenting.length > 0 %>
    <span class="field-label">presenting author:</span>
    <% abstracts_presenting.each do |abstract| %>
        <span><%= abstract[:abstract_title] %></span>
    <% end %>
    </p>
<% end %>


<!-- ======= inputs ======= -->
<div class="field">
    <%= fields_for :affiliation do |affiliation| %>
        <div class="author-row">
            <span class="author-col"><%= affiliation.select(:institution, options_for_select(institution_ids)) %></span>
            <span class="author-col"><%= affiliation.select(:department, options_for_select(department_ids)) %></span>
        </div>
        <div class="author-row">
            <span class="author-col"><%= affiliation.text_field "institution_text", value: "Cornell University" %></span>
            <span class="author-col"><%= affiliation.text_field "department_text", value: "Geology" %></span>
        <%= affiliation.hidden_field :affiliation_id, id: "affiliation_id", value: 0 %>
        </div>
    <% end %>
</div>


<%= user.hidden_field :user_type, id: "user_type", value: "corresponding" %>


<% abstracts_primary = Abstract.where(:id IN ()) %>
<% puts "abstracts_primary: #{abstracts_primary.inspect}" %>
<% abstracts_secondary = Abstract.where(:secondary_author_id => @user[:id]) %>
<% puts "abstracts_secondary: #{abstracts_secondary.inspect}" %>
<% abstracts_presenting = Abstract.where(:presenting_author_id => @user[:id]) %>
<% puts "abstracts_presenting: #{abstracts_presenting.inspect}" %>


params.require(:abstract).permit(:reviewer1_id, :reviewer2_id, :corr_author_id, :abs_title, :abs_text, :present_request, :present_actual, :invited)


def abstract_params
    params.require(:abstract).permit(:reviewer1_id, :reviewer2_id, :corr_author_id, :abs_title, :abs_text, :present_request, :present_actual, :invited, :accepted, author: [:firstname, :lastname], affiliation: [:institution, :department])
    params.require(:author).permit(:firstname, :lastname)
    params.require(:affiliation).permit(:institution, :department)
end


# @abstract = Abstract.new(ok_params[:abstract_attributes])
# @author = Abstract.new(ok_params[:author_attributes])
# @affiliation = Abstract.new(ok_params[:affiliation_attributes])


<%= form_with(model: abstract, local: true) do |f| %>


def abstract_params
    params.require(:abstract).permit(:corr_author_id, :abstract_title, :abstract_text, :primary_author_id, :secondary_author_id, :submitting_author_id, :presenting_author_id, :present_actual, :invited, :present_pref, :accepted)
end


<div class="field">
    <%= f.label "secondary author" %><br />
    <%= f.select(:secondary_author_id, options_for_select(user_name_ids, selected_secondary)) %>
</div>
<div class="field">
    <%= f.label "presenting author" %><br />
    <%= f.select(:presenting_author_id, options_for_select(user_name_ids, selected_presenting)) %>
</div>


<% selected_primary = nil %>
<% selected_secondary = nil %>
<% selected_submitting = current_user[:id] %>
<% selected_presenting = nil %>

<% if @abstract[:primary_author_id] %>
    <% selected_primary = @abstract[:primary_author_id] %>
<% end %>
<% if @abstract[:secondary_author_id] %>
    <% selected_secondary = @abstract[:secondary_author_id] %>
<% end %>
<% if @abstract[:presenting_author_id] %>
    <% selected_submitting = @abstract[:presenting_author_id] %>
<% end %>
<% if @abstract[:submitting_author_id] %>
    <% selected_presenting = @abstract[:submitting_author_id] %>
<% end %>
<% user_name_ids = [] %>
<% @users.each_with_index do |user, index| %>
    <% fullname = user[:firstname] + " " + user[:lastname] %>
    <% user_name_ids << [fullname, user[:id]] %>
<% end %>


<div class="field">
    <h4>Participation</h4>
    <% if abstracts_primary.length > 0 %>
        <p><span class="field-label">primary author:</span>
        <% abstracts_primary.each do |abstract| %>
            <span><%= abstract[:abstract_title] %></span>
        <% end %>
        </p>
    <% end %>

    <% if abstracts_secondary.length > 0 %>
        <span class="field-label">secondary author:</span>
        <% abstracts_secondary.each do |abstract| %>
            <span><%= abstract[:abstract_title] %></span>
        <% end %>
        </p>
    <% end %>

    <% if abstracts_presenting.length > 0 %>
        <span class="field-label">presenting author:</span>
        <% abstracts_presenting.each do |abstract| %>
            <span><%= abstract[:abstract_title] %></span>
        <% end %>
        </p>
    <% end %>
</div>


<% abstracts_primary = Abstract.where(:primary_author_id => @user[:id]) %>
<% puts "abstracts_primary: #{abstracts_primary.inspect}" %>
<% abstracts_secondary = Abstract.where(:secondary_author_id => @user[:id]) %>
<% puts "abstracts_secondary: #{abstracts_secondary.inspect}" %>
<% abstracts_presenting = Abstract.where(:presenting_author_id => @user[:id]) %>
<% puts "abstracts_presenting: #{abstracts_presenting.inspect}" %>



<% if @affiliations %>
  <div class="field">
      <%= f.label :affiliation_id %><br />
      <%= f.select(:affiliation_id, options_for_select(affiliation_name_ids, selected_affiliation)) %>
  </div>
<% end %>



<!-- ======= build affiliation selectbox ======= -->
<% selected_affiliation = nil %>
<% if @user[:affiliation_id] %>
    <% selected_affiliation = @user[:affiliation_id] %>
<% end %>
<% if @affiliations %>
    <% affiliation_name_ids = [] %>
    <% @affiliations.each_with_index do |affiliation, index| %>
        <% affiliation_name_ids << [affiliation[:institution], affiliation[:id]] %>
    <% end %>
<% end %>



<div class="field">
  <%= f.label :author_type %><br />
  primary <%= radio_button("user", "author_type", "primary") %>
  secondary <%= radio_button("user", "author_type", "secondary") %>
  presenting<%= check_box("user", "present") %>
  submitting <%= check_box("user", "submit") %>
</div>
