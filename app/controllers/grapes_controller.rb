class GrapesController < ApplicationController
  before_action :set_grape, only: [:show, :edit, :update, :destroy]

  # GET /grapes
  # GET /grapes.json
  def index
    @grapes = Grape.all
  end

  # GET /grapes/1
  # GET /grapes/1.json
  def show
  end

  # GET /grapes/new
  def new
    @grape = Grape.new
    @grapenames = Grapename.all
  end

  # GET /grapes/1/edit
  def edit
    @grapenames = Grapename.all
  end

  # POST /grapes
  # POST /grapes.json
  def create
    @grape = Grape.new(grape_params)
    @grape.grapename = Grapename.find( params[ :grapename ] )
    respond_to do |format|
      if @grape.save
        format.html { redirect_to @grape, notice: 'Grape was successfully created.' }
        format.json { render :show, status: :created, location: @grape }
      else
        format.html { render :new }
        format.json { render json: @grape.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /grapes/1
  # PATCH/PUT /grapes/1.json
  def update
    respond_to do |format|
      if @grape.update(grape_params)
        format.html { redirect_to @grape, notice: 'Grape was successfully updated.' }
        format.json { render :show, status: :ok, location: @grape }
      else
        format.html { render :edit }
        format.json { render json: @grape.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /grapes/1
  # DELETE /grapes/1.json
  def destroy
    @grape.destroy
    respond_to do |format|
      format.html { redirect_to grapes_url, notice: 'Grape was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_grape
      @grape = Grape.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def grape_params
      params.require(:grape).permit(:grapename_id, :quantity)
    end
end
