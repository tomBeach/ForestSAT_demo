class PresentationsController < ApplicationController
    before_action :set_presentation, only: [:show, :edit, :update, :destroy]

    # session_org, session_chair, room, session_type, session_title, session_start, 

    # ======= edit =======
    def edit
        puts"******* edit *******"
        @abstracts = Abstract.all
        @rooms = Room.all
    end

    # ======= update =======
    def update
        puts"******* update *******"
        respond_to do |format|
            if @presentation.update(presentation_params)
                format.html { redirect_to @presentation, notice: 'Session was successfully updated.' }
            else
                format.html { render :edit }
            end
        end
    end

  # GET /presentations
  # GET /presentations.json
  def index
    @presentations = Presentation.all
  end

  # GET /presentations/1
  # GET /presentations/1.json
  def show
  end

  # GET /presentations/new
  def new
    @presentation = Presentation.new
  end

  # POST /presentations
  # POST /presentations.json
  def create
    @presentation = Presentation.new(presentation_params)

    respond_to do |format|
      if @presentation.save
        format.html { redirect_to @presentation, notice: 'Session was successfully created.' }
        format.json { render :show, status: :created, location: @presentation }
      else
        format.html { render :new }
        format.json { render json: @presentation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /presentations/1
  # DELETE /presentations/1.json
  def destroy
    @presentation.destroy
    respond_to do |format|
      format.html { redirect_to presentations_url, notice: 'Session was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

    private
        # Use callbacks to share common setup or constraints between actions.
        def set_presentation
          @presentation = Presentation.find(params[:id])
        end

        # Never trust parameters from the scary internet, only allow the white list through.
        def presentation_params
            params.require(:presentation).permit(:abstract_id, :poster_location, :session_type, :session_code, :session_room, :session_datetime, :session_sequence)
        end
end
