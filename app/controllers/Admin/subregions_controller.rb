class Admin::SubregionsController < ApplicationController
  include GenericImporter
  layout "admin"
  before_action :authenticate_user!
  authorize_actions_for AdminAuthorizer # Triggers user check
  before_action :set_subregion, only: [:show, :edit, :update, :destroy]

  # GET /subregions
  # GET /subregions.json
  def index
    @subregions = Subregion.all.order(:id)
  end

  # GET /subregions/1
  # GET /subregions/1.json
  def show
  end

  # GET /subregions/new
  def new
    @subregion = Subregion.new
    @regions = Region.all
  end

  # GET /subregions/1/edit
  def edit
    @regions = Region.all
  end

  # POST /subregions
  # POST /subregions.json
  def create
    @subregion = Subregion.new(subregion_params)
    @subregion.region = Region.find( params[ :region_id ] )
    respond_to do |format|
      if @subregion.save
        format.html { redirect_to [:admin, @subregion], notice: 'Subregion was successfully created.' }
        format.json { render :show, status: :created, location: @subregion }
      else
        format.html { render :new }
        format.json { render json: @subregion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /subregions/1
  # PATCH/PUT /subregions/1.json
  def update
    respond_to do |format|
      if @subregion.update(subregion_params)
        format.html { redirect_to [:admin, @subregion], notice: 'Subregion was successfully updated.' }
        format.json { render :show, status: :ok, location: @subregion }
      else
        format.html { render :edit }
        format.json { render json: @subregion.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subregions/1
  # DELETE /subregions/1.json
  def destroy
    @subregion.destroy
    respond_to do |format|
      format.html { redirect_to admin_subregions_url, notice: 'Subregion was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def import
    results = import_data(params[:file], :subregions, %w(subregion_id name region_id))

    if results[:success]
      respond_to do |format|
        format.html { redirect_to admin_subregions_path, notice: 'Subregions were successfully uploaded.' }
      end
    else
      respond_to do |format|
        format.html { redirect_to upload_admin_subregions_path, alert: results[:errors].join(', ') }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subregion
      @subregion = Subregion.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def subregion_params
      params.require(:subregion).permit(:name, :region_id)
    end
end
