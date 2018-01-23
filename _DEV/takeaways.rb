======= takeaways =======

== multiple OR selections
    @abstracts = Abstract.where("keyword_1 = ? OR keyword_2 = ? OR keyword_3 = ?", "1", "2", "3")

== multiple join tables
    sql = "SELECT authors.id,
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
        WHERE abstract_authors.abstract_id = '" + abstract[:id].to_s + "'
    ORDER BY abstract_authors.author_type;"
    authors_collection = ActiveRecord::Base.connection.execute(sql)

== convert result to array (for later processing)
    authors_data_array = authors_collection.to_a

== eliminate duplication based on unique id as key and arrays as values
    authors_data = {}
    authors_data_array.each do |author|
        if !authors_data[author["id"]]
            authors_data[author["id"]] = { id:author["id"], name:author["firstname"] + " " + author["lastname"], affls:[author["institution"] + "/" + author["department"]], author_type:author["author_type"] }
        else
            affiliation = author["institution"] + "/" + author["department"]
            if !authors_data[author["id"]][:affls].include? affiliation
                authors_data[author["id"]][:affls].push(affiliation)
            end
        end
    end

== data for multiple tables in one form
    ok_params = abstract_params         # an array of data by table type
    abs_params = ok_params[0]           # abstract table data
    author_params = ok_params[1]        # author table data
    affiliation_params = ok_params[2]   # affiliation table data
    author_type_params = ok_params[3]   # author_type table data

    # = strong params process
    def abstract_params
        puts "******* abstract_params *******"
        ok_params = []
        ok_params << params.require(:abstract).permit(:id, ...:invited, :paper)
        ok_params << params.require(:author).permit(:corr_firstname, :corr_lastname, :firstnames => [], :lastnames => [])
        ok_params << params.require(:affiliation).permit(:corr_institution, ...:institutions => [], :departments => [])
        ok_params << params.require(:abstract_author).permit(:corr_author_type, :author_types => [])
        ok_params << params.permit(:id)
        return ok_params
    end

== looping through multiple arrays of form data
    author_params[:firstnames].each_with_index do |firstname, index|    # arrays have equal length (index works for all arrays)
        lastname = author_params[:lastnames][index]                     # extract from lastname array
        institution = affiliation_params[:institutions][index]          # extract from institutions array
        department = affiliation_params[:departments][index]            # extract from departments array
        author_type = author_type_params[:author_types][index]          # extract from author_types array

== screen for authors not in database based on firstname/lastname
    @author = Author.get_author(firstname, lastname)                    # this is inside above each loop
    if !@author
        @author = Author.new(:firstname => firstname, :lastname => lastname)    # create new record

== merge two collections without duplicates
    abstracts = (author_abstracts + corr_abstracts).uniq

== hash with id as key
    authors_data = {}
    authors_data_array.each do |author|
        if !authors_data[author["id"]]                                      # check for author[:id] key
            authors_data[author["id"]] = { name:author["firstname"], ...}   # add key and set its value to sub-hash
        ...

== OR selections ordered by column name
    @abstracts = Abstract.where("reviewer1_id = ? OR reviewer2_id = ?", current_user[:id], current_user[:id]).order("abs_title")

== multiple keyword selection
    # ======= filter_by_keyword =======
    def filter_by_keyword
        puts "\n******* filter_by_keyword *******"
        ok_params = filter_params
        puts "\nok_params: #{ok_params.inspect}"
        puts "params[:keyword_1]: #{params[:keyword_1].inspect}"
        puts "params[:keyword_2]: #{params[:keyword_2].inspect}"
        puts "params[:keyword_3]: #{params[:keyword_3].inspect}"

        sql_array = []          # holds keyword names (extracted from records, used in query)
        keyword_array = []      # holds submitted keyword records (based on submitted ids)
        query_array = []        # components of sql statement
        keyword_string = ""     # provides feedback to user (which keywords used in query)
        query_string = ""       # holds sql that selects based on submitted keywords

        # == any combination of three keywords can be used for filtering
        if params[:keyword_1].length > 0
            keyword_1 = Keyword.select(:keyword_name).find(params[:keyword_1])
            keyword_array << keyword_1
            sql_array << params[:keyword_1]
            query_array << "keyword_1 = ?"
        end
        if params[:keyword_2].length > 0
            keyword_2 = Keyword.select(:keyword_name).find(params[:keyword_2])
            keyword_array << keyword_2
            sql_array << params[:keyword_2]
            query_array << "keyword_2 = ?"
        end
        if params[:keyword_3].length > 0
            keyword_3 = Keyword.select(:keyword_name).find(params[:keyword_3])
            keyword_array << keyword_3
            sql_array << params[:keyword_3]
            query_array << "keyword_3 = ?"
        end
        puts "query_array: #{query_array.inspect}"
        puts "sql_array: #{sql_array.inspect}"
        puts "keyword_array: #{keyword_array.inspect}"

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

            # == final assembly of sql query
            sql_array = sql_array.unshift(query_string)
            @abstracts = Abstract.where(sql_array)
        else
            @abstracts = Abstract.all
        end

        # == get current keyword lists by type
        @users = User.all.order("lastname")
        @keywords = Keyword.all
        flash.now[:notice] = "Selection by keywords: " + keyword_string
        respond_to do |format|
            format.html { render :select_abstracts }
        end
    end

    == view for multiple keywords
    <% user_name_ids = [] %>
    <% @users.each_with_index do |user, index| %>
        <% fullname = user[:firstname] + " " + user[:lastname] %>
        <% user_name_ids << [fullname, user[:id]] %>
    <% end %>
    <% keywords1 = [nil] %>
    <% @keywords.each_with_index do |keyword, index| %>
        <% keywords1 << [keyword[:keyword_name], keyword[:id]] %>
    <% end %>
    <% keywords2 = [nil] %>
    <% @keywords.each_with_index do |keyword, index| %>
        <% keywords2 << [keyword[:keyword_name], keyword[:id]] %>
    <% end %>
    <% keywords3 = [nil] %>
    <% @keywords.each_with_index do |keyword, index| %>
        <% keywords3 << [keyword[:keyword_name], keyword[:id]] %>
    <% end %>
