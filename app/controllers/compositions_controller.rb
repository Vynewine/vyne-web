class CompositionsController < ApplicationController
  layout "admin"
  before_action :authenticate_user!
  authorize_actions_for SupplierAuthorizer # Triggers user check
  before_action :set_grape, only: [:show, :edit, :update, :destroy]

  # GET /compositions
  # GET /compositions.json
  def index
    @compositions = Composition.all
  end

  # GET /compositions/1
  # GET /compositions/1.json
  def show
  end

  # GET /compositions/new
  def new
    @grape = Composition.new
    @grapenames = Grape.all
  end

  # GET /compositions/1/edit
  def edit
    @grapenames = Grape.all
  end

  # POST /compositions
  # POST /compositions.json
  def create
    @grape = Composition.new(grape_params)
    @grape.grapename = Grape.find( params[ :grapename ] )
    respond_to do |format|
      if @grape.save
        format.html { redirect_to @grape, notice: 'Composition was successfully created.' }
        format.json { render :show, status: :created, location: @grape }
      else
        format.html { render :new }
        format.json { render json: @grape.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /compositions/1
  # PATCH/PUT /compositions/1.json
  def update
    respond_to do |format|
      if @grape.update(grape_params)
        format.html { redirect_to @grape, notice: 'Composition was successfully updated.' }
        format.json { render :show, status: :ok, location: @grape }
      else
        format.html { render :edit }
        format.json { render json: @grape.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /compositions/1
  # DELETE /compositions/1.json
  def destroy
    @grape.destroy
    respond_to do |format|
      format.html { redirect_to compositions_url, notice: 'Composition was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_grape
      @grape = Composition.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def grape_params
      params.require(:composition).permit(:grape_id, :quantity)
    end
end
