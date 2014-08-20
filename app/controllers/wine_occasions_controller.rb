class WineOccasionsController < ApplicationController
  before_action :set_wine_occasion, only: [:show, :edit, :update, :destroy]

  # GET /wine_occasions
  # GET /wine_occasions.json
  def index
    @wine_occasions = WineOccasion.all
  end

  # GET /wine_occasions/1
  # GET /wine_occasions/1.json
  def show
  end

  # GET /wine_occasions/new
  def new
    @wine_occasion = WineOccasion.new
  end

  # GET /wine_occasions/1/edit
  def edit
  end

  # POST /wine_occasions
  # POST /wine_occasions.json
  def create
    @wine_occasion = WineOccasion.new(wine_occasion_params)

    respond_to do |format|
      if @wine_occasion.save
        format.html { redirect_to @wine_occasion, notice: 'Wine occasion was successfully created.' }
        format.json { render :show, status: :created, location: @wine_occasion }
      else
        format.html { render :new }
        format.json { render json: @wine_occasion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /wine_occasions/1
  # PATCH/PUT /wine_occasions/1.json
  def update
    respond_to do |format|
      if @wine_occasion.update(wine_occasion_params)
        format.html { redirect_to @wine_occasion, notice: 'Wine occasion was successfully updated.' }
        format.json { render :show, status: :ok, location: @wine_occasion }
      else
        format.html { render :edit }
        format.json { render json: @wine_occasion.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wine_occasions/1
  # DELETE /wine_occasions/1.json
  def destroy
    @wine_occasion.destroy
    respond_to do |format|
      format.html { redirect_to wine_occasions_url, notice: 'Wine occasion was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wine_occasion
      @wine_occasion = WineOccasion.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def wine_occasion_params
      params.require(:wine_occasion).permit(:name)
    end
end
