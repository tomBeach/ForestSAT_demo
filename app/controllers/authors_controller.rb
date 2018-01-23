class AuthorsController < ApplicationController
    before_action :set_author, only: [:show, :edit, :update, :destroy]

    # ======= index =======
    def index
        puts "\n******* index *******"
        @authors = Author.all
    end

    # ======= get_author_data =======
    def get_author_data(author)
        puts "\n******* get_author_data *******"
        sql = "SELECT authors.id,
            authors.firstname,
            authors.lastname,
            author_affiliations.affiliation_id,
            affiliations.institution,
            affiliations.department
        FROM authors
        INNER JOIN author_affiliations
            on authors.id = author_affiliations.author_id
        INNER JOIN affiliations
            on affiliations.id = author_affiliations.affiliation_id
            WHERE author_affiliations.author_id = '" + author[:id].to_s + "';"
        author_data = ActiveRecord::Base.connection.execute(sql)
        author_data_array = author_data.to_a
        puts "author_data_array: #{author_data_array.inspect}"

        # == parse data into primary and secondary authors/affiliations
        authors_data = {}

        author_data_array.each do |author|
            if !authors_data[author["id"]]
                authors_data[author["id"]] = { firstname:author["firstname"], lastname:author["lastname"], affl_ids:[author["affiliation_id"]], institutions:[author["institution"]], departments:[author["department"]] }
            else
                if !authors_data[author["id"]][:institutions].include? author["institution"]
                    authors_data[author["id"]][:institutions].push(author["institution"])
                    authors_data[author["id"]][:departments].push(author["department"])
                    authors_data[author["id"]][:affl_ids].push(author["affiliation_id"])
                end
                puts "...[:institutions]: #{authors_data[author["id"]][:institutions].inspect}"
                puts "...[:departments]: #{authors_data[author["id"]][:departments].inspect}"
            end
        end
        puts "authors_data: #{authors_data.inspect}"
        return authors_data
    end

    # ======= show =======
    def show
        puts "\n******* show *******"
        if @author[:user_id]
            @admin_reviewer = User.select(:admin, :reviewer).find(@author[:user_id])
            puts "@admin_reviewer: #{@admin_reviewer.inspect}"
        end

        author_data = get_author_data(@author)
        puts "author_data: #{author_data.inspect}"
        @author_data_values = author_data[@author[:id]]
        puts "@author_data_values: #{@author_data_values.inspect}"
    end

    # GET /authors/new
    def new
        @author = Author.new
    end

    # ======= create =======
    def create
        puts "\n******* create *******"
        ok_params = new_author_params
        author_params = ok_params[0]
        affiliation_params = ok_params[1]
        @author = Author.new(author_params)

        respond_to do |format|
            if @author.save
                notice = 'Author was successfully created.'
                puts "+++ NEW AUTHOR +++"
                @affiliation = Affiliation.where(:institution => affiliation_params[:institution], :department => affiliation_params[:department]).first
                puts "+++ existing affiliation +++"
                if !@affiliation
                    @affiliation = Affiliation.create(affiliation_params)
                    if @affiliation
                        @author_affiliation = AuthorAffiliation.create(:author_id => @author[:id], :affiliation_id => @affiliation[:id])
                        if @author_affiliation
                            notice += '; Author affiliation was successfully created.'
                            puts "+++ NEW affiliation +++"
                        end
                    end
                end
                puts "@affiliation: #{@affiliation.inspect}"
                format.html { redirect_to @author, notice: notice }
            else
                format.html { render :new }
            end
        end
    end

    # ======= edit =======
    def edit
        puts "\n******* edit *******"
        author_data = get_author_data(@author)
        puts "author_data: #{author_data.inspect}"
        @author_data_values = author_data[@author[:id]]
        puts "@author_data_values: #{@author_data_values.inspect}"
    end

    # ======= update =======
    def update
        puts "\n******* update *******"
        puts "params: #{params.inspect}"

        ok_params = author_affl_params
        puts "\nok_params: #{ok_params.inspect}"
        author_params = ok_params[0]
        puts "\nauthor_params: #{author_params.inspect}"
        affiliation_params = ok_params[1]
        puts "\naffiliation_params: #{affiliation_params.inspect}"
        puts "\naffiliation_params[:new_institution].length: #{affiliation_params[:new_institution].length.inspect}"
        puts "\n...length: #{affiliation_params[:new_institution].length.inspect}"

        respond_to do |format|
            if @author.update(author_params)
                affiliation_params[:affl_ids].each_with_index do |affl_id, index|
                    institution = affiliation_params[:institutions][index]
                    department = affiliation_params[:departments][index]
                    next_affl = Affiliation.find(affl_id.to_i)
                    next_affl.update(:institution => institution, :department => department)
                end
                if affiliation_params[:new_institution].length > 0
                    puts "+++ new_institution DATA PRESENT +++"
                    check_affl = Affiliation.where(:institution => affiliation_params[:new_institution], :department => affiliation_params[:new_department]).first
                    puts "check_affl: #{check_affl.inspect}"
                    if !check_affl
                        new_affl = Affiliation.create(:institution => affiliation_params[:new_institution], :department => affiliation_params[:new_department])
                        if new_affl
                            AuthorAffiliation.create(:author_id => @author[:id], :affiliation_id => new_affl[:id])
                        end
                    end
                end
                format.html { redirect_to @author, notice: 'Author was successfully updated.' }
            else
                format.html { render :edit }
            end
        end
    end


  # DELETE /authors/1
  # DELETE /authors/1.json
  def destroy
    @author.destroy
    respond_to do |format|
      format.html { redirect_to authors_url, notice: 'Author was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

    private
        # Use callbacks to share common setup or constraints between actions.
        def set_author
            @author = Author.find(params[:id])
        end

        def new_author_params
            puts "******* new_author_params *******"
            ok_params = []
            ok_params << params.require(:author).permit(:firstname, :lastname)
            ok_params << params.require(:affiliation).permit(:institution, :department)
            return ok_params
        end

        def author_affl_params
            puts "******* author_affl_params *******"
            ok_params = []
            ok_params << params.require(:author).permit(:firstname, :lastname)
            ok_params << params.require(:affiliation).permit(:new_institution, :new_department, :affl_ids => [], :institutions => [], :departments => [], :delete_affiliation => [])
            return ok_params
        end
end
