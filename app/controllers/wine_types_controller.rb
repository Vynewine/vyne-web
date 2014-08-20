class WineTypesController < ApplicationController
  before_action :set_wine_type, only: [:show, :edit, :update, :destroy]

  # GET /wine_types
  # GET /wine_types.json
  def index
    @wine_types = WineType.all
  end

  # GET /wine_types/1
  # GET /wine_types/1.json
  def show
  end

  # GET /wine_types/new
  def new
    @wine_type = WineType.new
  end

  # GET /wine_types/1/edit
  def edit
  end

  # POST /wine_types
  # POST /wine_types.json
  def create
    @wine_type = WineType.new(wine_type_params)

    respond_to do |format|
      if @wine_type.save
        format.html { redirect_to @wine_type, notice: 'Wine type was successfully created.' }
        format.json { render :show, status: :created, location: @wine_type }
      else
        format.html { render :new }
        format.json { render json: @wine_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /wine_types/1
  # PATCH/PUT /wine_types/1.json
  def update
    respond_to do |format|
      if @wine_type.update(wine_type_params)
        format.html { redirect_to @wine_type, notice: 'Wine type was successfully updated.' }
        format.json { render :show, status: :ok, location: @wine_type }
      else
        format.html { render :edit }
        format.json { render json: @wine_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wine_types/1
  # DELETE /wine_types/1.json
  def destroy
    @wine_type.destroy
    respond_to do |format|
      format.html { redirect_to wine_types_url, notice: 'Wine type was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wine_type
      @wine_type = WineType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def wine_type_params
      params.require(:wine_type).permit(:name)
    end
end
