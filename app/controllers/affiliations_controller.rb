class AffiliationsController < ApplicationController
    before_action :set_affiliation, only: [:show, :edit, :update, :destroy]

    # ======= index =======
    def index
        puts "\n******* index *******"
        @affiliations = Affiliation.all
    end

    # ======= new_author_affiliation =======
    def new_author_affiliation
        puts "\n******* new_author_affiliation *******"
        puts "params: #{params.inspect}"
        @author = Author.find(params[:author_id])
        puts "@author: #{@author.inspect}"
        check_affiliation = Affiliation.where(:institution => current_user[:institution], :department => current_user[:department]).first
        puts "check_affiliation1: #{check_affiliation.inspect}"
        if check_affiliation
            check_affiliation.update(:author_id => params[:author_id])
            puts "check_affiliation2: #{check_affiliation.inspect}"
            respond_to do |format|
                format.html { redirect_to user_path(current_user), notice: "New user/author linked to affiliation." }
            end
        else
            @affiliation = Affiliation.create(:institution => current_user[:institution], :department => current_user[:department], :author_id => params[:author_id])
            puts "@affiliation: #{@affiliation.inspect}"
            if @affiliation
                respond_to do |format|
                    format.html { redirect_to user_path(current_user), notice: "New affiliation created for new user." }
                end
            else
                flash[:notice] = "Affiliation missing for new user/author.  Please add affiliation."
                render :new
            end
        end
    end

    # ======= new =======
    def new
        puts "\n******* new *******"
        @affiliation = Affiliation.new
    end

    # ======= create =======
    def create
        puts "\n******* create *******"
        @affiliation = Affiliation.new(affiliation_params)

        respond_to do |format|
            if @affiliation.save
                format.html { redirect_to @affiliation, notice: 'Affiliation was successfully created.' }
            else
                format.html { render :new }
            end
        end
    end

  # GET /affiliations/1
  # GET /affiliations/1.json
  def show
  end

  # GET /affiliations/1/edit
  def edit
  end

  # PATCH/PUT /affiliations/1
  # PATCH/PUT /affiliations/1.json
  def update
    respond_to do |format|
      if @affiliation.update(affiliation_params)
        format.html { redirect_to @affiliation, notice: 'Affiliation was successfully updated.' }
        format.json { render :show, status: :ok, location: @affiliation }
      else
        format.html { render :edit }
        format.json { render json: @affiliation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /affiliations/1
  # DELETE /affiliations/1.json
  def destroy
    @affiliation.destroy
    respond_to do |format|
      format.html { redirect_to affiliations_url, notice: 'Affiliation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

    private
        def set_affiliation
            @affiliation = Affiliation.find(params[:id])
        end

        def affiliation_params
            puts "******* affiliation_params *******"
            params.require(:affiliation).permit(:institution, :department, :author_id)
        end
end
