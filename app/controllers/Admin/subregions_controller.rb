class Admin::SubregionsController < ApplicationController
  include GenericImporter
  layout 'admin'
  before_action :authenticate_user!
  authorize_actions_for AdminAuthorizer
  before_action :set_subregion, only: [:show, :edit, :update, :destroy]

  def index
    @subregions = Subregion.order(:id).page(params[:page])
  end

  def show
  end

  def new
    @subregion = Subregion.new
    @regions = Region.all.order(:name)
  end

  def edit
    @regions = Region.all.order(:name)
  end

  def create
    @subregion = Subregion.new(subregion_params)

    if @subregion.save
      redirect_to admin_subregion_path(@subregion), notice: 'Subregion was successfully created.'
    else
      @regions = Region.all.order(:name)
      flash.now[:error] = @subregion.errors.full_messages.join(', ')
      render :new
    end
  end

  def update

    if @subregion.update(subregion_params)
      redirect_to admin_subregion_path(@subregion), notice: 'Subregion was successfully updated.'
    else
      @regions = Region.all.order(:name)
      flash.now[:error] = @subregion.errors.full_messages.join(', ')
      render :edit
    end
  end

  def destroy
    @subregion.destroy
    redirect_to admin_subregions_url, notice: 'Subregion was successfully destroyed.'
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
  def set_subregion
    @subregion = Subregion.find(params[:id])
  end

  def subregion_params
    params.require(:subregion).permit(:name, :region_id)
  end
end
