class AbstractsController < ApplicationController
    before_action :set_abstract, only: [:show, :edit, :destroy]

    # ======= index =======
    def index
        puts "\n******* index/my_abstracts *******"
        abstracts = Abstract.all

        # == match author and abstract data in array of objects: { abstract: abstract, authors: authors_data }
        @abstract_data_array = process_abstract_data(abstracts)
        @title = "Abstracts"
        render :my_abstracts
    end

    # ======= get_abs_comment =======
    def get_abs_comment
        puts "\n******* get_abs_comment *******"
        puts "params: #{params.inspect}"
        abstract = Abstract.find(params[:abstract_id].to_i)
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
        puts "params: #{params.inspect}"
        abstract = Abstract.find(params[:abstract_id].to_i)
        if params[:which_reviewer] == "reviewer1"
            abstract.update(:reviewer1_comment => params[:abstract_comment])    # +++++++
        else
            abstract.update(:reviewer2_comment => params[:abstract_comment])    # +++++++
        end

        short_title = abstract[:abs_title][0..25]
        puts "short_title: #{short_title.inspect}"
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
        puts "params: #{params.inspect}"

        abstract = Abstract.find(params[:abstract_id].to_i)
        puts "abstract: #{abstract.inspect}"
        respond_to do |format|
            format.json {
                render json: {:abs_comment => abstract[:abs_comment]}
            }
        end
    end

    # ======= my_abstracts =======
    def my_abstracts
        puts "\n******* my_abstracts *******"

        # == get author record for current_user
        author = Author.where(:firstname => current_user.firstname, :lastname => current_user.lastname).first
        puts "author: #{author.inspect}"

        # == get abstracts where current_user is primary or secondary author
        if author
            abstracts = author.abstracts
            puts "abstracts.length: #{abstracts.length.inspect}"
        else
            abstracts = []
        end

        # == get abstracts where current_user is corresponding or presenting author
        corr_abstracts = Abstract.where("corr_author_id = " + current_user[:id].to_s + " OR pres_author_id = " + current_user[:id].to_s)
        puts "corr_abstracts.length: #{corr_abstracts.length.inspect}"

        # == merge both selections without duplication
        abstracts = (abstracts + corr_abstracts).uniq
        puts "abstracts.length: #{abstracts.length.inspect}"

        if abstracts.length < 1
            @abstract_data_array = []
            flash.now[:notice] = "No abstracts are currently linked to your account."
        else
            @abstract_data_array = process_abstract_data(abstracts)
        end
        @title = "My Abstracts"
        render :my_abstracts
    end

    # ======= review_abstracts =======
    def review_abstracts
        puts "\n******* review_abstracts *******"
        @users = User.all.order("lastname")

        # == this view uses wider table
        @wide_flag = true

        # == get abstracts where current_user is listed as a reviewer
        @abstracts = Abstract.where("reviewer1_id = ? OR reviewer2_id = ?", current_user[:id], current_user[:id]).order("abs_title")
        puts "@abstracts: #{@abstracts.inspect}"
    end

    # ======= save_all_reviews =======
    def save_all_reviews
        puts "\n******* save_all_reviews *******"
        puts "params: #{params.inspect}"
        ok_params = rec_grade_params
        puts "\nok_params: #{ok_params.inspect}"

        # == loop through matched param arrays (ids, recs, grades)
        ok_params[:abstract_ids].each_with_index do |abstract_id, index|
            puts "\nabstract_id: #{abstract_id.inspect}"

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
        flash.now[:notice] = message
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
    # == create admin screen for selecting/rejecting abstracts
    def select_abstracts
        puts "\n******* select_abstracts *******"
        @wide_flag = true
        @users = User.all.order("lastname")
        @keywords = Keyword.all
        @abstracts = Abstract.all.order("abs_title")
    end

    # ======= save_selection =======
    # == save admin selection ()
    def save_selection
        puts "\n******* save_selection *******"
        ok_params = selection_params
        puts "\nok_params: #{ok_params.inspect}"
        notice_array = ["abstracts evaluated: "]
        notice_string = ""

        if ok_params[:abstract_id] == "all"
            ok_params[:abstract_ids].each_with_index do |abstract_id, index|
                admin_final = ok_params[:admin_finals][index]
                @abstract = Abstract.find(abstract_id)
                @abstract.update(:admin_final => admin_final)
                notice_array << abstract_id.to_s + ": " + @abstract[:abs_title][0...24] + "... "
                if index < (ok_params[:abstract_ids].length - 1)
                    notice_array << ", "
                end
            end
        else
            flash.now[:notice] = 'Selected abstract status updated successfully.'
            @abstract = Abstract.find(ok_params[:abstract_id])
            @abstract.update(:admin_final => ok_params[:admin_final])
        end
        puts "notice_array: #{notice_array.inspect}"

        notice_array.each_with_index do |notice, index|
            notice_string += notice
        end
        respond_to do |format|
            format.html { redirect_to :select_abstracts, notice: notice_string }
        end
    end

    # ======= signup_abstract =======
    def signup_abstract
        puts "\n******* signup_abstract *******"
        @abstracts = Abstract.all
    end

    # ======= new =======
    def new
        puts "\n******* new *******"
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
        puts "@abstract: #{@abstract.inspect}"

        # == save abstract
        @abstract = Abstract.new(abs_params)
        respond_to do |format|
            if @abstract.save
                puts "\n++++++ abstract NEW OK +++++++"

                # == add submitter designation for corresponding author (submitter)
                current_user.update(:submitter => true)

                # == loop through author/affiliation params arrays (firstnames/lastnames/institution/department/author_types)
                author_params[:firstnames].each_with_index do |firstname, index|
                    lastname = author_params[:lastnames][index]
                    institution = affiliation_params[:institutions][index]
                    department = affiliation_params[:departments][index]
                    author_type = author_type_params[:author_types][index]

                    # == check if author is already in database
                    author = Author.get_author(firstname, lastname)

                    # == author not in database; create new author
                    if !author
                        author = Author.new(:firstname => firstname, :lastname => lastname)

                        # == save author
                        if author.save
                            puts "++++++ author NEW OK +++++++"
                            author = Author.order("created_at").last

                            # == set author as "presenting" if index matches radiobutton presenting author index
                            if index == pres_author_index.to_i
                                @abstract.update(:pres_author_id => author[:id])
                                pres_author = Author.find(author[:id])
                            end

                            # == create join table abstract/author link with author_type (primary/secondary)
                            abstract_author = AbstractAuthor.new(:abstract_id => @abstract[:id].to_i, :author_id => author[:id].to_i, :author_type => author_type)
                            if abstract_author.save
                                puts "++++++ abstract_author NEW OK +++++++"
                            else
                                puts "++++++ abstract_author FAIL +++++++"
                                flash.now[:notice] = 'Author type data was not saved.  Please contact the administrator.'
                            end

                            # == save new affiliation if required
                            affiliation = Affiliation.where(:institution => institution, :department => department).first
                            puts "\naffiliation: #{affiliation.inspect}"
                            if !affiliation
                                aa = make_new_author_affiliation(author, institution, department)
                                affiliation = aa[0]
                                author_affiliation = aa[1]
                            else
                                author_affiliations = author.affiliations.where(affiliation[:id] => affiliation[:id])
                                puts "author_affiliations: #{author_affiliations.inspect}"
                            end
                        end

                    # == author already in database; create join table abstract/author link with author_type
                    else
                        puts "++++++ existing author +++++++"
                        puts "author_type2: #{author_type.inspect}"

                        # == check if author has existing affiliation
                        affiliation = Affiliation.where(:institution => institution, :department => department).first
                        puts "\naffiliation: #{affiliation.inspect}"

                        # == create new affiliation (author has more than one)
                        if !affiliation
                            aa = make_new_author_affiliation(author, institution, department)
                            affiliation = aa[0]
                            author_affiliation = aa[1]
                        end

                        # == identify presenting author
                        if index == pres_author_index.to_i
                            puts "@abstract[:pres_author_id]1: #{@abstract[:pres_author_id].inspect}"
                            @abstract.update(:pres_author_id => author[:id])
                            puts "@abstract[:pres_author_id]2: #{@abstract[:pres_author_id].inspect}"
                            pres_author = Author.find(author[:id])
                        end

                        abstract_author = AbstractAuthor.new(:abstract_id => @abstract[:id].to_i, :author_id => author[:id].to_i, :author_type => author_type)
                        puts "abstract_author2: #{abstract_author.inspect}"
                        if abstract_author.save
                            puts "++++++ abstract_author NEW OK +++++++"
                        else
                            puts "++++++ abstract_author FAIL +++++++"
                            flash.now[:notice] = 'Join table save failed.  Please try again.'
                        end
                    end
                end
                abstract_authors = @abstract.authors
                puts "\nabstract_authors.length: #{abstract_authors.length.inspect}"
                format.html { redirect_to @abstract, notice: 'Abstract, authors and affiliations all successfully created.' }
            else
                puts "++++++ abstract FAIL +++++++"
                format.html { redirect_to new_abstract_path, notice: 'There was a problem saving your abstract. Please try again.' }
            end
        end

    end

    # ======= edit =======
    def edit
        puts "\n******* edit *******"
        @users = User.all

        # == get author data from authors, abstract_authors and affiliations
        @authors_data_array = get_extended_author_data(@abstract)
        puts "\n@authors_data_array: #{@authors_data_array.inspect}"
        puts "\n@authors_data_array.length: #{@authors_data_array.length.inspect}"

        @authors_data = make_author_affiliations_objects(@authors_data_array)

        # == generate list of keywords for selectboxes
        @keywords = Keyword.all
    end

    # ======= update =======
    def update
        puts "\n******* update *******"
        ok_params = update_params

        abs_params = ok_params[0]
        author_params = ok_params[1]
        affiliation_params = ok_params[2]
        author_type_params = ok_params[3]
        abstract_id = ok_params[4]

        @abstract = Abstract.find(abs_params[:id])

        puts "\nparams: #{params.inspect}"
        puts "\nok_params: #{ok_params.inspect}"
        puts "\nabs_params: #{abs_params.inspect}"
        puts "\nauthor_params: #{author_params.inspect}"
        puts "\nauthor_type_params: #{author_type_params.inspect}"
        puts "\naffiliation_params: #{affiliation_params.inspect}"
        puts "\nabstract_id: #{abstract_id.inspect}"
        puts "@abstract: #{@abstract.inspect}"

        if !abs_params[:invited]
            puts "+++++ NO INVITED VALUE +++++"
            abs_params.merge!(invited: false)
        end
        if !abs_params[:paper]
            puts "+++++ NO PAPER VALUE +++++"
            abs_params.merge!(paper: false)
        end

        current_abstract_authors = AbstractAuthor.where(:abstract_id => @abstract[:id]).pluck(:author_id)
        puts "current_abstract_authors: #{current_abstract_authors.inspect}"

        # == get author data from authors, abstract_authors and affiliations
        sql = "SELECT authors.id, abstract_authors.abstract_id, abstract_authors.author_type FROM authors
        INNER JOIN abstract_authors
            on authors.id = abstract_authors.author_id
        WHERE abstract_authors.author_type = 'primary' AND abstract_authors.abstract_id = " + @abstract[:id].to_s + ";"

        primary_author = ActiveRecord::Base.connection.execute(sql)
        @primary_author = primary_author.to_a
        puts "\n@primary_author: #{@primary_author.inspect}"
        puts "@primary_author.length: #{@primary_author.length.inspect}"
        puts "@primary_author[0][id]: #{@primary_author[0]["id"].inspect}"

        # == remove authors with delete_author checkbox id
        if author_params[:delete_authors]
            puts "@abstract[:pres_author_id]: #{@abstract[:pres_author_id].inspect}"
            author_params[:delete_authors].each_with_index do |author_id, index|
                abstract_author = AbstractAuthor.where(:author_id => author_id.to_i).first
                puts "author_id: #{author_id.inspect}"
                puts "abstract_author: #{abstract_author.inspect}"
                if abstract_author
                    abstract_author.destroy
                    puts "+++++ abstract_author.destroy +++++"

                    # == check if deleted author was set as presenting author (default to primary)
                    if author_id.to_i == @abstract[:pres_author_id]
                        puts "++++++ presenting author DELETED/primary = presenting +++++++"
                        puts "abs_params[:pres_author_id]: #{abs_params[:pres_author_id].inspect}"
                        abs_params[:pres_author_id] = @primary_author[0]["id"]
                    end
                end
            end
        end

        # == add new author if values are present
        if author_params[:new_firstname] != ""
            author = Author.get_author(author_params[:new_firstname], author_params[:new_lastname])
            if !author
                author = Author.new(:firstname => author_params[:new_firstname], :lastname => author_params[:new_lastname])

                # == save author
                if author.save
                    puts "++++++ author NEW OK +++++++"
                    author = Author.order("created_at").last

                    # == create join table abstract/author link with author_type (primary/secondary)
                    @abstract_author = AbstractAuthor.new(:abstract_id => @abstract[:id].to_i, :author_id => author[:id].to_i, :author_type => author_type_params[:new_author_type])
                    if @abstract_author.save
                        puts "++++++ abstract_author NEW OK +++++++"
                    else
                        puts "++++++ abstract_author FAIL +++++++"
                        flash.now[:notice] = 'Join table save failed.  Please try again.'
                    end

                    # == save affiliation
                    affiliation = Affiliation.where(:institution => affiliation_params[:new_institution], :department => affiliation_params[:new_department]).first
                    if !affiliation
                        affiliation = Affiliation.new(:institution => affiliation_params[:new_institution], :department => affiliation_params[:new_department])
                        puts "affiliation new: #{affiliation.inspect}"
                        if affiliation.save
                            puts "++++++ affiliation NEW OK +++++++"
                        else
                            puts "++++++ affiliation FAIL +++++++"
                            flash.now[:notice] = 'Affiliation save failed.  Please try again.'
                        end
                    end
                    puts "affiliation new2: #{affiliation.inspect}"
                    # author_affiliations = author.author_affiliations
                    # puts "author_affiliations1: #{author_affiliations.inspect}"
                    author_affiliation = AuthorAffiliation.where(:author_id => author[:id]).first
                    if !author_affiliation
                        author_affiliation = AuthorAffiliation.create(:author_id => author[:id], :affiliation_id => affiliation[:id])
                    end
                    puts "author_affiliation2: #{author_affiliation.inspect}"
                end
            else
                # == create join table abstract/author link with author_type (primary/secondary)
                @abstract_author = AbstractAuthor.new(:abstract_id => @abstract[:id].to_i, :author_id => author[:id].to_i, :author_type => author_params[:new_author_type])
                if @abstract_author.save
                    puts "++++++ abstract_author NEW OK +++++++"
                else
                    puts "++++++ abstract_author FAIL +++++++"
                    flash.now[:notice] = 'Join table save failed.  Please try again.'
                end
            end
        end

        respond_to do |format|
            if @abstract.update(abs_params)
                format.html { redirect_to @abstract, notice: 'Abstract was successfully updated.' }
            else
                format.html { render :edit }
            end
        end
    end

    # ======= show =======
    def show
        puts "\n******* show *******"
        puts "@abstract: #{@abstract.inspect}"
        puts "current_user[:admin]: #{current_user[:admin].inspect}"

        # == allow administrators to edit abstract
        @edit_flag = false
        if current_user[:admin] == true
            @edit_flag = true
        end
        puts "@edit_flag: #{@edit_flag.inspect}"

        # == get author data from authors, abstract_authors and affiliations
        authors_data_array = get_extended_author_data(@abstract)

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
        puts "@corr_author_name: #{@corr_author_name.inspect}"

        # == get presenting author affiliations
        if @abstract[:pres_author_id]
            @pres_author_string = ""
            pres_author = Author.find(@abstract[:pres_author_id])
            puts "pres_author: #{pres_author.inspect}"
            @pres_author_string += pres_author.full_name + " ("
            pres_author_affls = pres_author.affiliations
            puts "pres_author_affls: #{pres_author_affls.inspect}"

            # == create author-name/multiple-affiliations string
            pres_author_affls.each_with_index do |affl, index|
                @pres_author_string += affl[:institution] + "/" + affl[:department]
                if index == (pres_author_affls.length - 1)
                    @pres_author_string += ")"
                else
                    @pres_author_string += ", "
                end
            end
        else
            @pres_author_string = "missing data"
        end
        puts "@pres_author_string: #{@pres_author_string.inspect}"

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
        if @abstract[:present_id]
            present = Presentation.find(@abstract[:present_id])
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

    # ======= filter_by_keyword =======
    def filter_by_keyword
        puts "\n******* filter_by_keyword *******"

        @wide_flag = true
        ok_params = filter_params
        puts "\nok_params: #{ok_params.inspect}"
        puts "params[:keyword_1]: #{params[:keyword_1].inspect}"

        if params[:keyword_1].length > 0
            key_id = params[:keyword_1]
            puts "key_id: #{key_id.inspect}"
            selected_keyword = Keyword.where(id: key_id).pluck(:keyword_name).first
            puts "selected_keyword: #{selected_keyword.inspect}"
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

    # ======= make_new_author_affiliation =======
    def make_new_author_affiliation(author, institution, department)
        puts "\n******* make_new_author_affiliation *******"
        affiliation = Affiliation.new(:institution => institution, :department => department)
        puts "affiliation new: #{affiliation.inspect}"
        if affiliation.save
            puts "++++++ affiliation NEW OK +++++++"

            # == create join table author/affiliation link
            author_affiliation = AuthorAffiliation.new(:author_id => author[:id], :affiliation_id => affiliation[:id])

            if author_affiliation.save
                puts "++++++ author_affiliation NEW OK +++++++"
                puts "author_affiliation: #{author_affiliation.inspect}"
            else
                puts "++++++ author_affiliation FAIL +++++++"
                flash.now[:notice] = 'Author affiliation failed to save.  Please contact administrator.'
            end
        else
            puts "++++++ affiliation FAIL +++++++"
            flash.now[:notice] = 'Author affiliation failed to save.  Please contact administrator.'
        end
        return [affiliation, author_affiliation]
    end

    # ======= process_abstract_data =======
    def process_abstract_data(abstracts)
        puts "\n******* process_abstract_data *******"
        @abstract_data_array = []

        # == loop through all abstracts; extract author data for each abstract
        abstracts.each do |abstract|

            # == get authors, author_types and affiliations for each abstract
            authors_data_array = get_extended_author_data(abstract)

            # == parse data into authors_data hash with primary and secondary authors/affiliations
            authors_data = make_author_affiliations_objects(authors_data_array)

            # == add abstract and authors_data hash to master hash; push to array
            abstract_data = { abstract: abstract, authors: authors_data }
            @abstract_data_array.push(abstract_data)
        end
        puts "@abstract_data_array: #{@abstract_data_array.inspect}"
        puts "@abstract_data_array.length: #{@abstract_data_array.length.inspect}"
        return @abstract_data_array
    end

    # ======= make_author_affiliations_objects =======
    def make_author_affiliations_objects(authors_data_array)
        puts "\n******* make_author_affiliations_objects *******"
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
        return authors_data
    end

    # ======= get_extended_author_data =======
    def get_extended_author_data(abstract)
        puts "\n******* get_extended_author_data *******"
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
        return authors_collection.to_a
    end

    private
        def set_abstract
            puts "\n******* set_abstract *******"
            puts "params: #{params.inspect}"
            @abstract = Abstract.find(params[:id])
        end

        def update_params
            puts "\n******* update_params *******"
            ok_params = []
            ok_params << params.require(:abstract).permit(:id, :corr_author_id, :pres_author_id, :reviewer1_id, :reviewer2_id, :presentation_id, :session_sequence, :abs_title, :abs_text, :keyword_1, :keyword_2, :keyword_3, :present_request, :present_assigned, :reviewer1_rec, :reviewer2_rec, :accepted, :invited, :paper)
            ok_params << params.require(:author).permit(:corr_firstname, :corr_lastname, :new_firstname, :new_lastname, :delete_authors => [])
            ok_params << params.require(:affiliation).permit(:corr_institution, :corr_department, :new_institution, :new_department)
            ok_params << params.require(:abstract_author).permit(:corr_author_type, :new_author_type)
            ok_params << params.permit(:id)
            return ok_params
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
end
