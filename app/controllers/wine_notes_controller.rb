class WineNotesController < ApplicationController
  before_action :set_wine_note, only: [:show, :edit, :update, :destroy]

  # GET /wine_notes
  # GET /wine_notes.json
  def index
    @wine_notes = WineNote.all
  end

  # GET /wine_notes/1
  # GET /wine_notes/1.json
  def show
  end

  # GET /wine_notes/new
  def new
    @wine_note = WineNote.new
  end

  # GET /wine_notes/1/edit
  def edit
  end

  # POST /wine_notes
  # POST /wine_notes.json
  def create
    @wine_note = WineNote.new(wine_note_params)

    respond_to do |format|
      if @wine_note.save
        format.html { redirect_to @wine_note, notice: 'Wine note was successfully created.' }
        format.json { render :show, status: :created, location: @wine_note }
      else
        format.html { render :new }
        format.json { render json: @wine_note.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /wine_notes/1
  # PATCH/PUT /wine_notes/1.json
  def update
    respond_to do |format|
      if @wine_note.update(wine_note_params)
        format.html { redirect_to @wine_note, notice: 'Wine note was successfully updated.' }
        format.json { render :show, status: :ok, location: @wine_note }
      else
        format.html { render :edit }
        format.json { render json: @wine_note.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wine_notes/1
  # DELETE /wine_notes/1.json
  def destroy
    @wine_note.destroy
    respond_to do |format|
      format.html { redirect_to wine_notes_url, notice: 'Wine note was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wine_note
      @wine_note = WineNote.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def wine_note_params
      params.require(:wine_note).permit(:name)
    end
end
