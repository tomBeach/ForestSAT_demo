<h1>Assign Reviewers</h1>

<!-- ======= users selectbox ======= -->
<% user_name_ids = [] %>
<% @users.each_with_index do |user, index| %>
    <% fullname = user[:firstname] + " " + user[:lastname] %>
    <% user_name_ids << [fullname, user[:id]] %>
<% end %>

<%= form_for("save_reviewers", url: "/save_reviewers", :html => {:id => "save_reviewers"}) do %>

    <%= fields_for :abstract do |a| %>
        <%= a.hidden_field :abstract_id %>
        <%= a.hidden_field :reviewer1_id %>
        <%= a.hidden_field :reviewer2_id %>

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
                    <% selected_reviewer1 = User.find(next_abstract[:reviewer1_id]) %>
                    <% selected_reviewer_id1 = selected_reviewer1[:id] %>
                <% end %>
                <% if next_abstract[:reviewer2_id] %>
                    <% selected_reviewer2 = User.find(next_abstract[:reviewer2_id]) %>
                    <% selected_reviewer_id2 = selected_reviewer2[:id] %>
                <% end %>

                <% sql = "SELECT authors.firstname, authors.lastname, abstract_authors.author_type FROM authors INNER JOIN abstract_authors ON authors.id = abstract_authors.author_id WHERE abstract_authors.abstract_id = '" + next_abstract[:id].to_s + "' AND abstract_authors.author_type = 'primary';" %>
                <% author_data = ActiveRecord::Base.connection.execute(sql) %>
                <% primary_author = author_data[0]["firstname"].to_s + " " + author_data[0]["lastname"].to_s %>

                <tr>
                    <td><%= link_to next_abstract[:abs_title], abstract_path(next_abstract) %></td>
                    <td><%= primary_author %></td>
                    <td><%= select_tag("abstract[reviewer1_ids][]", options_for_select(user_name_ids, selected_reviewer_id1), :id => "abstract_reviewer1_ids_" + next_abstract[:id].to_s) %></td>
                    <td><%= select_tag("abstract[reviewer2_ids][]", options_for_select(user_name_ids, selected_reviewer_id2), :id => "abstract_reviewer2_ids_" + next_abstract[:id].to_s) %></td>
                    <td>
                        <%= hidden_field_tag "abstract[abstract_ids][]", next_abstract[:id].to_s %>
                        <%= a.button "save", type: "button", id: "save_reviewers_" + next_abstract[:id].to_s, class: "submit_reviewers" %>
                    </td>
                    <% formatted_date = next_abstract[:updated_at].strftime('%a %b %d %l:%M') %>
                    <td>updated: <%= formatted_date %> </td>
                </tr>
            <% end %>

            <!-- ======= save all changes option ======= -->
            <tr>
                <td colspan="3"></td>
                <td colspan="3"><%= a.button "Save all changes", type: "button", id: "save_all_reviewers" %></td>
            </tr>
        </table>
    <% end %>
<% end %>

# ======= controller processing =======
# == save reviewers for each abstract (single save disabled)
def save_reviewers
    puts "\n******* save_reviewers *******"
    ok_params = reviewer_params
    puts "\nok_params: #{ok_params.inspect}"

    # == save all abstract updates
    if ok_params[:abstract_id] == "all"
        ok_params[:abstract_ids].each_with_index do |abstract_id, index|
            reviewer1_id = ok_params[:reviewer1_ids][index]
            reviewer2_id = ok_params[:reviewer2_ids][index]
            @abstract = Abstract.find(abstract_id)
            @abstract.update(:reviewer1_id => reviewer1_id, :reviewer2_id => reviewer2_id)
        end
        flash[:notice] = 'All reviewer changes updated successfully.'
        redirect_to :assign_reviewers

    # == save selected abstract changes (disabled)
    else
        flash[:notice] = 'Selected abstract status updated successfully.'
        @abstract = Abstract.find(ok_params[:abstract_id])
        @abstract.update(:reviewer1_id => ok_params[:reviewer1_id], :reviewer2_id => ok_params[:reviewer2_id])
        redirect_to :assign_reviewers
    end
end
