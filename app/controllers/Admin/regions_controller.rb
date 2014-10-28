class Admin::RegionsController < ApplicationController
  include GenericImporter
  layout "admin"
  before_action :authenticate_user!
  authorize_actions_for SupplierAuthorizer # Triggers user check
  before_action :set_region, only: [:show, :edit, :update, :destroy]

  # GET /regions
  # GET /regions.json
  def index
    @regions = Region.all.order(:id)
  end

  # GET /regions/1
  # GET /regions/1.json
  def show
  end

  # GET /regions/new
  def new
    @region = Region.new
    @countries = Country.all
  end

  # GET /regions/1/edit
  def edit
    @countries = Country.all
  end

  # POST /regions
  # POST /regions.json
  def create
    @region = Region.new(region_params)
    @region.country = Country.find( params[ :country ] )
    respond_to do |format|
      if @region.save
        format.html { redirect_to [:admin, @region], notice: 'Region was successfully created.' }
        format.json { render :show, status: :created, location: @region }
      else
        format.html { render :new }
        format.json { render json: @region.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /regions/1
  # PATCH/PUT /regions/1.json
  def update
    @region.country = Country.find( params[ :country ] )
    respond_to do |format|
      if @region.update(region_params)
        format.html { redirect_to [:admin, @region], notice: 'Region was successfully updated.' }
        format.json { render :show, status: :ok, location: @region }
      else
        format.html { render :edit }
        format.json { render json: @region.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /regions/1
  # DELETE /regions/1.json
  def destroy
    @region.destroy
    respond_to do |format|
      format.html { redirect_to admin_regions_url, notice: 'Region was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def import
    results = import_data(params[:file], :regions)

    if results[:success]
      respond_to do |format|
        format.html { redirect_to admin_regions_path, notice: 'Regions were successfully uploaded.' }
      end
    else
      respond_to do |format|
        format.html { redirect_to upload_admin_regions_path, alert: results[:errors].join(', ') }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_region
      @region = Region.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def region_params
      params.require(:region).permit(:name, :country)
    end
end
