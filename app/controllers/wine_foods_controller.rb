class WineFoodsController < ApplicationController
  before_action :set_wine_food, only: [:show, :edit, :update, :destroy]

  # GET /wine_foods
  # GET /wine_foods.json
  def index
    @wine_foods = WineFood.all
  end

  # GET /wine_foods/1
  # GET /wine_foods/1.json
  def show
  end

  # GET /wine_foods/new
  def new
    @wine_food = WineFood.new
  end

  # GET /wine_foods/1/edit
  def edit
  end

  # POST /wine_foods
  # POST /wine_foods.json
  def create
    @wine_food = WineFood.new(wine_food_params)

    respond_to do |format|
      if @wine_food.save
        format.html { redirect_to @wine_food, notice: 'Wine food was successfully created.' }
        format.json { render :show, status: :created, location: @wine_food }
      else
        format.html { render :new }
        format.json { render json: @wine_food.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /wine_foods/1
  # PATCH/PUT /wine_foods/1.json
  def update
    respond_to do |format|
      if @wine_food.update(wine_food_params)
        format.html { redirect_to @wine_food, notice: 'Wine food was successfully updated.' }
        format.json { render :show, status: :ok, location: @wine_food }
      else
        format.html { render :edit }
        format.json { render json: @wine_food.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wine_foods/1
  # DELETE /wine_foods/1.json
  def destroy
    @wine_food.destroy
    respond_to do |format|
      format.html { redirect_to wine_foods_url, notice: 'Wine food was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wine_food
      @wine_food = WineFood.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def wine_food_params
      params.require(:wine_food).permit(:name)
    end
end
