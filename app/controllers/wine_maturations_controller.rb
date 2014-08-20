class WineMaturationsController < ApplicationController
  before_action :set_wine_maturation, only: [:show, :edit, :update, :destroy]

  # GET /wine_maturations
  # GET /wine_maturations.json
  def index
    @wine_maturations = WineMaturation.all
  end

  # GET /wine_maturations/1
  # GET /wine_maturations/1.json
  def show
  end

  # GET /wine_maturations/new
  def new
    @wine_maturation = WineMaturation.new
    @maturationTypes = MaturationType.all
  end

  # GET /wine_maturations/1/edit
  def edit
    @maturationTypes = MaturationType.all
  end

  # POST /wine_maturations
  # POST /wine_maturations.json
  def create
    @wine_maturation = WineMaturation.new(wine_maturation_params)
    @wine_maturation.maturation_type = MaturationType.find( params[ :maturation_type_id ] )
    respond_to do |format|
      if @wine_maturation.save
        format.html { redirect_to @wine_maturation, notice: 'Wine maturation was successfully created.' }
        format.json { render :show, status: :created, location: @wine_maturation }
      else
        format.html { render :new }
        format.json { render json: @wine_maturation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /wine_maturations/1
  # PATCH/PUT /wine_maturations/1.json
  def update
    @wine_maturation.maturation_type = MaturationType.find( params[ :maturation_type_id ] )
    respond_to do |format|
      if @wine_maturation.update(wine_maturation_params)
        format.html { redirect_to @wine_maturation, notice: 'Wine maturation was successfully updated.' }
        format.json { render :show, status: :ok, location: @wine_maturation }
      else
        format.html { render :edit }
        format.json { render json: @wine_maturation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wine_maturations/1
  # DELETE /wine_maturations/1.json
  def destroy
    @wine_maturation.destroy
    respond_to do |format|
      format.html { redirect_to wine_maturations_url, notice: 'Wine maturation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wine_maturation
      @wine_maturation = WineMaturation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def wine_maturation_params
      params.require(:wine_maturation).permit(:maturation_type_id, :period)
    end
end
