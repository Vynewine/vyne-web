class WineAllergiesController < ApplicationController
  before_action :set_wine_allergy, only: [:show, :edit, :update, :destroy]

  # GET /wine_allergies
  # GET /wine_allergies.json
  def index
    @wine_allergies = WineAllergy.all
  end

  # GET /wine_allergies/1
  # GET /wine_allergies/1.json
  def show
  end

  # GET /wine_allergies/new
  def new
    @wine_allergy = WineAllergy.new
  end

  # GET /wine_allergies/1/edit
  def edit
  end

  # POST /wine_allergies
  # POST /wine_allergies.json
  def create
    @wine_allergy = WineAllergy.new(wine_allergy_params)

    respond_to do |format|
      if @wine_allergy.save
        format.html { redirect_to @wine_allergy, notice: 'Wine allergy was successfully created.' }
        format.json { render :show, status: :created, location: @wine_allergy }
      else
        format.html { render :new }
        format.json { render json: @wine_allergy.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /wine_allergies/1
  # PATCH/PUT /wine_allergies/1.json
  def update
    respond_to do |format|
      if @wine_allergy.update(wine_allergy_params)
        format.html { redirect_to @wine_allergy, notice: 'Wine allergy was successfully updated.' }
        format.json { render :show, status: :ok, location: @wine_allergy }
      else
        format.html { render :edit }
        format.json { render json: @wine_allergy.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wine_allergies/1
  # DELETE /wine_allergies/1.json
  def destroy
    @wine_allergy.destroy
    respond_to do |format|
      format.html { redirect_to wine_allergies_url, notice: 'Wine allergy was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wine_allergy
      @wine_allergy = WineAllergy.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def wine_allergy_params
      params.require(:wine_allergy).permit(:name)
    end
end
