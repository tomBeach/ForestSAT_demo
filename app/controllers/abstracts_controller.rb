class AbstractsController < ApplicationController
    before_action :set_abstract, only: [:show, :edit, :destroy]

    # ======= index =======
    def index
        puts "\n******* index/my_abstracts *******"

        # == title varies (all abstracts vs user-associated abstracts)
        @selected_type = ""
        @title = "Abstracts"
        @my = ""

        # == select based on admin_final category
        sql = "SELECT DISTINCT abstracts.* FROM authors INNER JOIN abstract_authors ON authors.id = abstract_authors.author_id INNER JOIN abstracts ON abstracts.id = abstract_authors.abstract_id "
        if params[:abstract]
            ok_params = filter_select_params
            @selected_type = ok_params[:select_type]
            if ok_params[:select_type] != "all"
                sql += "WHERE abstracts.admin_final = '" + ok_params[:select_type] + "'"
                message = "No abstracts currently match the *" + @selected_type + "* category."
            end
            if ok_params[:my_abstracts] == "my"
                sql += " AND (abstracts.corr_author_id = '" + current_user[:id].to_s + "' OR (authors.firstname = '" + current_user[:firstname] + "' AND authors.lastname = '" + current_user[:lastname] + "'))"
                message = "No abstracts linked to you as an author currently match the *" + @selected_type + "* category."
                @title = "My Abstracts"
                @my = "my"
            end

        # == select based on current_user as author and/or submitter (corresponding author)
        else
            if params[:my] == "my"
                sql += " AND (abstracts.corr_author_id = '" + current_user[:id].to_s + "' OR (authors.firstname = '" + current_user[:firstname] + "' AND authors.lastname = '" + current_user[:lastname] + "'))"
                @title = "My Abstracts"
                @my = "my"
            end
        end
        sql += ";"

        abstracts_collection = ActiveRecord::Base.connection.execute(sql)
        abstracts_collection_array = abstracts_collection.to_a

        if abstracts_collection_array.length > 0
            @abstract_data_array = process_abstract_data2(abstracts_collection_array)
        else
            message = "No abstracts currently match the selected category."
        end
        flash.now[:notice] = message
        render :my_abstracts
    end

    # ======= ======= ======= comments ======= ======= =======
    # ======= ======= ======= comments ======= ======= =======
    # ======= ======= ======= comments ======= ======= =======

    # ======= get_abs_comment =======
    def get_abs_comment
        puts "\n******* get_abs_comment *******"
        abstract = Abstract.find(params[:abstract_id].to_i)

        # == determine which reviewer comment was requested
        if abstract
            if params[:which_reviewer] == "reviewer1"
                abs_comment = abstract[:reviewer1_comment]
            else
                abs_comment = abstract[:reviewer2_comment]
            end
            if abs_comment
                respond_to do |format|
                    format.json {
                        render json: {:abs_comment => abs_comment}
                    }
                end
            else
                respond_to do |format|
                    format.json {
                        render json: {:abs_comment => ""}
                    }
                end
            end
        else
            redirect_to :review_abstracts
        end
    end

    # ======= save_abs_comment =======
    def save_abs_comment
        puts "\n******* save_abs_comment *******"

        abstract = Abstract.find(params[:abstract_id].to_i)
        if params[:which_reviewer] == "reviewer1"
            abstract.update(:reviewer1_comment => params[:abstract_comment])
        else
            abstract.update(:reviewer2_comment => params[:abstract_comment])
        end

        short_title = abstract[:abs_title][0..25]
        notice_text = "Your comment was saved for abstract <span class='hilite'>" + abstract[:id].to_s + "</span><br><span class='hilite'>(" + short_title + "...)</span>"

        respond_to do |format|
            format.json {
                render json: { :abs_comment => "", :notice => notice_text }
            }
        end
    end

    # ======= get_reviewer_comments =======
    def get_reviewer_comments
        puts "\n******* get_reviewer_comments *******"

        abstract = Abstract.find(params[:abstract_id].to_i)
        respond_to do |format|
            format.json {
                render json: {:abs_comment => abstract[:abs_comment]}
            }
        end
    end

    # ======= ======= ======= reviews ======= ======= =======
    # ======= ======= ======= reviews ======= ======= =======
    # ======= ======= ======= reviews ======= ======= =======

    # ======= review_abstracts =======
    def review_abstracts
        puts "\n******* review_abstracts *******"
        @users = User.all.order("lastname")

        # == this view uses wider table
        @wide_flag = true

        # == get abstracts where current_user is listed as a reviewer
        @abstracts = Abstract.where("reviewer1_id = ? OR reviewer2_id = ?", current_user[:id], current_user[:id]).order("abs_title")
    end

    # ======= save_all_reviews =======
    def save_all_reviews
        puts "\n******* save_all_reviews *******"

        ok_params = rec_grade_params

        # == loop through matched param arrays (ids, recs, grades)
        ok_params[:abstract_ids].each_with_index do |abstract_id, index|

            # == check keyword approvals
            if ok_params[:keywords_ok]
                if ok_params[:keywords_ok].include? abstract_id.to_s
                    keywords_ok = true
                else
                    keywords_ok = false
                end
            end

            # == get submitted grades and recommendations
            reviewer_rec = ok_params[:reviewer_recs][index]
            reviewer_grade = ok_params[:reviewer_grades][index]
            if reviewer_rec == 0
                reviewer_rec == nil
            end
            if reviewer_grade == 0
                reviewer_grade == nil
            end

            # == set reviewer recommendation/grade/keyword check in abstract record
            @abstract = Abstract.find(abstract_id)
            if ok_params[:which_reviewers][index] == "reviewer1"
                @abstract.update(:reviewer1_rec => reviewer_rec, :reviewer1_grade => reviewer_grade, :reviewer1_keywords => keywords_ok)
            else
                @abstract.update(:reviewer2_rec => reviewer_rec, :reviewer2_grade => reviewer_grade, :reviewer2_keywords => keywords_ok)
            end

        end

        message = 'Your recommendations have been saved to the database.'

        if current_user[:admin] == true
            respond_to do |format|
                format.html { redirect_to :select_abstracts, notice: message }
            end
        else
            respond_to do |format|
                format.html { redirect_to :home, notice: message }
            end
        end
    end

    # ======= select_abstracts =======
    def select_abstracts
        puts "\n******* select_abstracts *******"

        # == admin will review abstract recommendations/grades/comments
        @wide_flag = true
        @users = User.all.order("lastname")
        @keywords = Keyword.all
        @abstracts = Abstract.all.order("abs_title")
    end

    # ======= save_selection =======
    def save_selection
        puts "\n******* save_selection *******"
        ok_params = selection_params
        puts "\nok_params: #{ok_params.inspect}"

        # == start build of feedback message string
        notice_array = ["abstracts evaluated: "]
        notice_string = ""

        # == save results for reviewed abstracts (listed by id in :abstract_ids)
        if ok_params[:abstract_id] == "all"
            ok_params[:abstract_ids].each_with_index do |abstract_id, index|
                @abstract = Abstract.find(abstract_id)
                admin_final = ok_params[:admin_finals][index]
                if admin_final == "oral" || admin_final == "poster"
                    @abstract.update(:accepted => true, :admin_final => admin_final)
                else admin_final == "rejected"
                    @abstract.update(:accepted => false, :admin_final => admin_final)
                end
                notice_array << abstract_id.to_s + ": " + @abstract[:abs_title][0...24] + "... "
                if index < (ok_params[:abstract_ids].length - 1)
                    notice_array << ", "
                end
            end

        # == save results for single abstract
        else
            flash.now[:notice] = 'Selected abstract status updated successfully.'
            @abstract = Abstract.find(ok_params[:abstract_id])
            admin_final = ok_params[:admin_final]
            if admin_final == "oral" || admin_final == "poster"
                @abstract.update(:accepted => true, :admin_final => admin_final)
            else admin_final == "rejected"
                @abstract.update(:accepted => false, :admin_final => admin_final)
            end
        end

        # == display list of reviewed abstracts
        puts "notice_array: #{notice_array.inspect}"
        notice_array.each_with_index do |notice, index|
            notice_string += notice
        end
        respond_to do |format|
            format.html { redirect_to :select_abstracts, notice: notice_string }
        end
    end

    # ======= ======= ======= new ======= ======= =======
    # ======= ======= ======= new ======= ======= =======
    # ======= ======= ======= new ======= ======= =======

    # ======= new =======
    def new
        puts "\n******* abstracts/new *******"
        @keywords = Keyword.all
        @sessions = Presentation.where(:session_type => "special")
        @affiliations = Affiliation.all
        @abstract_author = AbstractAuthor.new
        @affiliation = Affiliation.new
        @abstract = Abstract.new
        @author = Author.new

        # == used by javascript via hidden field value (to show/hide new keyword entry)
        if current_user[:admin] == true
            @admin_flag = true
        else
            @admin_flag = false
        end
    end

    # ======= create =======
    def create
        puts "\n******* create *******"

        # == extract abstract/author/affiliation values from params
        ok_params = abstract_params
        abs_params = ok_params[0]
        author_params = ok_params[1]
        affiliation_params = ok_params[2]
        author_type_params = ok_params[3]

        # == get radiobutton index from checked radiobutton
        pres_author_index = abs_params[:pres_author_id]

        puts "\nparams: #{params.inspect}"
        puts "\nok_params: #{ok_params.inspect}"
        puts "\nabs_params: #{abs_params.inspect}"
        puts "\nauthor_params: #{author_params.inspect}"
        puts "\nauthor_type_params: #{author_type_params.inspect}"
        puts "\naffiliation_params: #{affiliation_params.inspect}"
        puts "\npres_author_index: #{pres_author_index.inspect}"

        # == save abstract
        @abstract = Abstract.create(abs_params)
        puts "@abstract: #{@abstract.inspect}"
        if @abstract.save
            puts "\n++++++ abstract NEW OK +++++++"

            # == add submitter designation for corresponding author (submitter)
            current_user.update(:submitter => true)

            # == loop through primary/secondary author/affiliation data
            author_params[:firstnames].each_with_index do |firstname, index|
                lastname = author_params[:lastnames][index]
                institution = affiliation_params[:institutions][index]
                department = affiliation_params[:departments][index]
                author_type = author_type_params[:author_types][index]

                author = check_new_author(firstname, lastname)
                link_new_author(@abstract, author, author_type)
                affiliation = check_new_affiliation(institution, department)
                link_new_affiliation(author, affiliation)
                update_pres_author(@abstract, author, index, pres_author_index)
            end

            respond_to do |format|
                format.html { redirect_to @abstract, notice: 'Abstract was successfully added.' }
            end
        else
            puts "\n++++++ abstract NEW FAILED +++++++"
            respond_to do |format|
                format.html { redirect_to :new, notice: 'There was a problem saving the abstract.  Please try again or contact the administrator.' }
            end
        end
    end

    # ======= ======= ======= edit ======= ======= =======
    # ======= ======= ======= edit ======= ======= =======
    # ======= ======= ======= edit ======= ======= =======

    # ======= get_primary_author =======
    def get_primary_author(abstract)
        puts "\n******* get_primary_author *******"
        sql = "SELECT authors.id, abstract_authors.abstract_id, abstract_authors.author_type FROM authors
        INNER JOIN abstract_authors ON authors.id = abstract_authors.author_id
        WHERE abstract_authors.author_type = 'primary' AND abstract_authors.abstract_id = " + abstract[:id].to_s + ";"
        primary_author = ActiveRecord::Base.connection.execute(sql).to_a.first
        return primary_author
    end

    # ======= edit =======
    def edit
        puts "\n******* edit *******"
        @users = User.all

        # == get author data from authors, abstract_authors and affiliations
        @authors_data_array = get_extended_author_data2(@abstract[:id])

        # == package multiple affiliations (if any) with each author
        @authors_data = make_author_affiliations_objects(@authors_data_array)

        # == get primary author data
        primary_author = get_primary_author(@abstract)
        @primary_author_id = primary_author["id"]

        # == generate list of keywords for selectboxes
        @keywords = Keyword.all

        # == generate list of special sessions for selectboxes
        @sessions = Presentation.all
    end

    # ======= update =======
    def update
        puts "\n******* update *******"

        # == extract abstract/author/affiliation values from params
        ok_params = update_params
        abs_params = ok_params[0]
        author_params = ok_params[1]
        affiliation_params = ok_params[2]
        author_type_params = ok_params[3]
        # abstract_id = ok_params[4]

        @abstract = Abstract.find(abs_params[:id])

        puts "\nparams: #{params.inspect}"
        puts "\nok_params: #{ok_params.inspect}"
        puts "\nabs_params: #{abs_params.inspect}"
        puts "\nauthor_params: #{author_params.inspect}"
        puts "\nauthor_type_params: #{author_type_params.inspect}"
        puts "\naffiliation_params: #{affiliation_params.inspect}"
        puts "\nabs_params[:id]: #{abs_params[:id].inspect}"

        # == no param values returned for these items if they are not checked
        if !abs_params[:invited]
            puts "+++++ NO INVITED VALUE +++++"
            abs_params.merge!(invited: false)
        end
        if !abs_params[:paper]
            puts "+++++ NO PAPER VALUE +++++"
            abs_params.merge!(paper: false)
        end

        # == get primary author data
        @primary_author = get_primary_author(@abstract)
        primary_author_id = @primary_author["id"]

        # == remove authors with ids listed in :delete_authors array (from delete_author checkbox values)
        if author_params[:delete_authors]

            author_params[:delete_authors].each_with_index do |author_id, index|

                # == delete author (primary author can not be deleted)
                if primary_author_id != author_id
                    delete_author = AbstractAuthor.where(:author_id => author_id.to_i).first
                    if delete_author
                        delete_author.destroy
                        puts "+++++ delete_author.destroy +++++"

                        # == check if deleted author was presenting author (replace with primary author)
                        if author_id.to_i == @abstract[:pres_author_id]
                            puts "++++++ presenting author DELETED/set presenting author to primary author +++++++"
                            abs_params[:pres_author_id] = primary_author_id
                            flash.now[:notice] = 'Deleted author was presenting author.  Presenting author is now defaulted to primary author.'
                        end
                    end
                end
            end
        end

        # == add new author/affiliation if values are present
        if author_params[:new_firstname] != ""

            firstname = author_params[:new_firstname]
            lastname = author_params[:new_lastname]
            institution = affiliation_params[:new_institution]
            department = affiliation_params[:new_department]

            author = check_new_author(firstname, lastname)
            link_new_author(@abstract, author, "secondary")
            affiliation = check_new_affiliation(institution, department)
            link_new_affiliation(author, affiliation)
        end

        respond_to do |format|
            if @abstract.update(abs_params)
                format.html { redirect_to @abstract, notice: 'Abstract was successfully updated.' }
            else
                format.html { render :edit }
            end
        end
    end

    # ======= ======= ======= abstract/author/affiliation relationships ======= ======= =======
    # ======= ======= ======= abstract/author/affiliation relationships ======= ======= =======
    # ======= ======= ======= abstract/author/affiliation relationships ======= ======= =======

    # ======= update_pres_author =======
    def update_pres_author(abstract, author, index, pres_author_index)
        puts "\n******* update_pres_author *******"
        if index == pres_author_index.to_i
            abstract.update(:pres_author_id => author[:id])
        end
    end

    # ======= link_new_affiliation =======
    def link_new_affiliation(author, affiliation)
        puts "\n******* link_new_affiliation *******"
        check_author_affiliation = AuthorAffiliation.where(:author_id => author[:id], :affiliation_id => affiliation[:id]).first
        if !check_author_affiliation
            check_author_affiliation = AuthorAffiliation.create(:author_id => author[:id], :affiliation_id => affiliation[:id])
        end
    end

    # ======= check_new_affiliation =======
    def check_new_affiliation(institution, department)
        puts "\n******* check_new_affiliation *******"
        check_affiliation = Affiliation.where(:institution => institution, :department => department).first
        if !check_affiliation
            check_affiliation = Affiliation.create(:institution => institution, :department => department)
        end
        return check_affiliation
    end

    # ======= link_new_author =======
    def link_new_author(abstract, author, author_type)
        puts "\n******* link_new_author *******"
        abstract_author = AbstractAuthor.create(:abstract_id => abstract[:id], :author_id => author[:id], :author_type => author_type)
    end

    # ======= check_new_author =======
    def check_new_author(firstname, lastname)
        puts "\n******* check_new_author *******"
        check_author = Author.where(:firstname => firstname, :lastname => lastname).first
        if !check_author
            check_author = Author.create(:firstname => firstname, :lastname => lastname)
        end
        return check_author
    end

    # ======= ======= ======= show ======= ======= =======
    # ======= ======= ======= show ======= ======= =======
    # ======= ======= ======= show ======= ======= =======

    # ======= show =======
    def show
        puts "\n******* show *******"

        # == allow administrators to edit abstract
        @edit_flag = false
        if current_user[:admin] == true
            @edit_flag = true
        end

        # == get author data from authors/abstract_authors/affiliations
        authors_data_array = get_extended_author_data2(@abstract[:id])

        # == parse data into primary and secondary authors/affiliations
        @authors_data = make_author_affiliations_objects(authors_data_array)

        # == get submitter name
        if @abstract[:corr_author_id]
            corr_author = User.find(@abstract[:corr_author_id])
            if corr_author
                @corr_author_name = corr_author.full_name
            else
                @corr_author_name = "missing data"
            end
        else
            @corr_author_name = "missing data"
        end

        # == get presenting author affiliations
        if @abstract[:pres_author_id]
            @pres_author_string = ""
            pres_author = Author.where(:id => @abstract[:pres_author_id]).first
            if pres_author
                @pres_author_string += pres_author.full_name + " ("
                pres_author_affls = pres_author.affiliations
            else
                @pres_author_string += "author/affiliations error"
            end

            # == create author-name/multiple-affiliations string
            if pres_author_affls
                pres_author_affls.each_with_index do |affl, index|
                    @pres_author_string += affl[:institution] + "/" + affl[:department]
                    if index == (pres_author_affls.length - 1)
                        @pres_author_string += ")"
                    else
                        @pres_author_string += ", "
                    end
                end
            end
        else
            @pres_author_string = "author/affiliations error"
        end

        # == identify reviewers assigned to abstract if any
        if @abstract[:reviewer1_id]
            reviewer1 = User.find(@abstract[:reviewer1_id])
            @reviewer1_name = reviewer1.full_name
        else
            @reviewer1_name = "unassigned"
        end
        if @abstract[:reviewer2_id]
            reviewer2 = User.find(@abstract[:reviewer2_id])
            @reviewer2_name = reviewer2.full_name
        else
            @reviewer2_name = "unassigned"
        end

        # == identify session (presentation) assigned for abstract if any
        if @abstract[:presentation_id]
            present = Presentation.find(@abstract[:presentation_id])
            @present = present[:session_title]
        else
            @present = "unassigned"
        end
    end

    # ======= destroy =======
    def destroy
        puts "\n******* destroy *******"
        @abstract.destroy
        respond_to do |format|
            format.html { redirect_to abstracts_url, notice: 'Abstract was successfully removed.' }
        end
    end

    # ======= ======= ======= filters ======= ======= =======
    # ======= ======= ======= filters ======= ======= =======
    # ======= ======= ======= filters ======= ======= =======

    # ======= filter_by_keyword =======
    def filter_by_keyword
        puts "\n******* filter_by_keyword *******"

        @wide_flag = true
        ok_params = filter_params

        if params[:keyword_1].length > 0
            key_id = params[:keyword_1]
            selected_keyword = Keyword.where(id: key_id).pluck(:keyword_name).first
            @abstracts = Abstract.where("keyword_1 = ? OR keyword_2 = ? OR keyword_3 = ?", key_id, key_id, key_id)
        else
            @abstracts = Abstract.all
        end

        # == get current keyword lists by type
        @users = User.all.order("lastname")
        @keywords = Keyword.all
        flash.now[:notice] = "Selection by keywords: " + selected_keyword
        respond_to do |format|
            format.html { render :select_abstracts }
        end
    end

    # ======= ======= ======= UTILITIES ======= ======= =======
    # ======= ======= ======= UTILITIES ======= ======= =======
    # ======= ======= ======= UTILITIES ======= ======= =======

    # ======= process_abstract_data2 =======
    def process_abstract_data2(abstracts_collection_array)
        puts "\n******* process_abstract_data2 *******"
        abstract_data_array = []

        # == loop through all abstracts; extract author data for each abstract
        abstracts_collection_array.each do |abstract|

            # == get authors, author_types and affiliations for each abstract
            authors_data_array = get_extended_author_data2(abstract["id"])

            # == parse data into authors_data hash with primary and secondary authors/affiliations
            authors_data = make_author_affiliations_objects(authors_data_array)

            # == add abstract and authors_data hash to master hash; push to array
            abstract_data = { abstract: abstract, authors: authors_data }
            abstract_data_array.push(abstract_data)
        end
        puts "abstract_data_array: #{abstract_data_array.inspect}"
        puts "abstract_data_array.length: #{abstract_data_array.length.inspect}"
        return abstract_data_array
    end

    # ======= make_author_affiliations_objects =======
    def make_author_affiliations_objects(authors_data_array)
        puts "\n******* make_author_affiliations_objects *******"
        authors_data = {}
        if authors_data_array.length > 0
            authors_data_array.each do |author|

                # == add author object if none already exists; set values for author/affiliation data
                if !authors_data[author["id"]]
                    authors_data[author["id"]] = { id:author["id"], name:author["firstname"] + " " + author["lastname"], affls:[author["institution"] + "/" + author["department"]], author_type:author["author_type"] }

                # == check if affiliation exists and and new affiliation if not
                else
                    affiliation = author["institution"] + "/" + author["department"]
                    if !authors_data[author["id"]][:affls].include? affiliation
                        authors_data[author["id"]][:affls].push(affiliation)
                    end
                end
            end
        end
        return authors_data
    end

    # ======= get_extended_author_data2 =======
    def get_extended_author_data2(abstract_id)
        puts "\n******* get_extended_author_data2 *******"
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
            WHERE abstract_authors.abstract_id = '" + abstract_id.to_s + "'
        ORDER BY abstract_authors.author_type;"
        authors_collection = ActiveRecord::Base.connection.execute(sql)
        return authors_collection.to_a
    end

    private
        def set_abstract
            puts "\n******* set_abstract *******"
            puts "params: #{params.inspect}"
            @abstract = Abstract.find(params[:id])
        end

        def abstract_params
            puts "******* abstract_params *******"
            ok_params = []
            ok_params << params.require(:abstract).permit(:id, :corr_author_id, :pres_author_id, :reviewer1_id, :reviewer2_id, :presentation_id, :session_sequence, :abs_title, :abs_text, :keyword_1, :keyword_2, :keyword_3, :present_request, :present_assigned, :reviewer1_rec, :reviewer2_rec, :accepted, :invited, :paper, :presentation_id)
            ok_params << params.require(:author).permit(:corr_firstname, :corr_lastname, :firstnames => [], :lastnames => [])
            ok_params << params.require(:affiliation).permit(:corr_institution, :corr_department, :institutions => [], :departments => [])
            ok_params << params.require(:abstract_author).permit(:corr_author_type, :author_types => [])
            ok_params << params.permit(:id)
            return ok_params
        end

        def update_params
            puts "\n******* update_params *******"
            ok_params = []
            ok_params << params.require(:abstract).permit(:id, :corr_author_id, :pres_author_id, :reviewer1_id, :reviewer2_id, :presentation_id, :session_sequence, :abs_title, :abs_text, :keyword_1, :keyword_2, :keyword_3, :present_request, :present_assigned, :reviewer1_rec, :reviewer2_rec, :accepted, :invited, :paper)
            ok_params << params.require(:author).permit(:corr_firstname, :corr_lastname, :new_firstname, :new_lastname, :delete_authors => [])
            ok_params << params.require(:affiliation).permit(:corr_institution, :corr_department, :new_institution, :new_department)
            ok_params << params.require(:abstract_author).permit(:corr_author_type, :new_author_type)
            # ok_params << params.permit(:id)
            return ok_params
        end

        def filter_select_params
            puts "******* filter_select_params *******"
            puts "params: #{params.inspect}"
            params.require(:abstract).permit(:select_type, :my_abstracts)
        end

        def filter_params
            puts "******* filter_params *******"
            params.permit(:keyword_1, :keyword_2, :keyword_3)
        end

        def rec_grade_params
            puts "******* rec_grade_params *******"
            params.require(:abstract).permit(:which_reviewers => [], :abstract_ids => [], :reviewer_recs => [], :reviewer_grades => [], :keywords_ok => [])
        end

        def selection_params
            puts "******* selection_params *******"
            params.require(:abstract).permit(:abstract_id, :admin_final, :admin_finals => [], :abstract_ids => [])
        end
end
