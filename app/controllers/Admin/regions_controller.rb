class Admin::RegionsController < ApplicationController
  include GenericImporter
  layout 'admin'
  before_action :authenticate_user!
  authorize_actions_for AdminAuthorizer # Triggers user check
  before_action :set_region, only: [:show, :edit, :update, :destroy]

  def index
    @regions = Region.order(:id).page(params[:page])
  end

  def show
  end

  def new
    @region = Region.new
    @countries = Country.all
  end

  def edit
    @countries = Country.all
  end

  def create
    @region = Region.new(region_params)
    if @region.save
      redirect_to admin_region_path(@region), notice: 'Region was successfully created.'
    else
      @countries = Country.all
      flash.now[:error] = @region.errors.full_messages.join(', ')
      render :new
    end
  end

  def update
    if @region.update(region_params)
      redirect_to admin_region_path(@region), notice: 'Region was successfully updated.'
    else
      @countries = Country.all
      flash.now[:error] = @region.errors.full_messages.join(', ')
      render :edit
    end
  end

  def destroy
    @region.destroy
    redirect_to admin_regions_url, notice: 'Region was successfully destroyed.'
  end

  def import
    results = import_data(params[:file], :regions, %w(region_id name country_id))

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

  def set_region
    @region = Region.find(params[:id])
  end

  def region_params
    params.require(:region).permit(:name, :country_id)
  end
end
