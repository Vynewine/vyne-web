class WinesController < ApplicationController
  layout "admin"
  before_filter :authenticate_user!
  before_action :set_wine, only: [:show, :edit, :update, :destroy]

  # GET /wines
  # GET /wines.json
  def index
    @wines = Wine.all
  end

  # GET /wines/1
  # GET /wines/1.json
  def show
  end

  # GET /wines/new
  def new
    @wine = Wine.new
    @producers = Producer.all
    @subregions = Subregion.all
    @appellations = Appellation.all
    @types = Type.all
    # @wine.occasions.build
    # @occasion.wine.build
    # 3.times { @wine.compositions.build }
    @wine.compositions.build
    # @compositions = @wine.compositions
  end

  # GET /wines/1/edit
  def edit
    @producers = Producer.all
    @subregions = Subregion.all
    @appellations = Appellation.all
    @types = Type.all
    # @grapes = Grape.all
    @occasions = Occasion.all
    @foods = Food.all
    @notes = Note.all
    @allergies = Allergy.all
    @maturations = Maturation.all
    # 3.times { @wine.occasions.build }
    @compositions = @wine.compositions
  end

  # POST /wines
  # POST /wines.json
  def create
    @wine = Wine.new(wine_params)
    params[:wine][:type_ids] ||= []
    respond_to do |format|
      if @wine.save
        format.html { redirect_to @wine, notice: 'Wine was successfully created.' }
        format.json { render :show, status: :created, location: @wine }
      else
        format.html { render :new }
        format.json { render json: @wine.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /wines/1
  # PATCH/PUT /wines/1.json
  def update
    params[:wine][:type_ids] ||= []
puts "-------------------------------"
puts params[:wine][:producer_id]
puts "-------------------------------"
    respond_to do |format|
      if @wine.update(wine_params)
        format.html { redirect_to @wine, notice: 'Wine was successfully updated.' }
        format.json { render :show, status: :ok, location: @wine }
      else
        format.html { render :edit }
        format.json { render json: @wine.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wines/1
  # DELETE /wines/1.json
  def destroy
    @wine.destroy
    respond_to do |format|
      format.html { redirect_to wines_url, notice: 'Wine was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wine
      @wine = Wine.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def wine_params
      params.require(:wine).permit(
        :name,
        :vintage,
        :area,
        :single_estate,
        :alcohol,
        :sugar,
        :acidity,
        :ph,
        :vegetarian,
        :vegan,
        :organic,
        :producer_id,
        :subregion_id,
        :appellation_id,
        :occasion_tokens,
        :food_tokens,
        :note_tokens,
        type_ids: [],
        occasions_attributes: [:name],
        :compositions_attributes => [:id, :grape_id, :quantity]
      )
      # params.require(:wine).permit()
    end
end
