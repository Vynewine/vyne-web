class Admin::AppellationsController < ApplicationController
  include GenericImporter
  layout 'admin'
  before_action :authenticate_user!
  authorize_actions_for AdminAuthorizer # Triggers user check
  before_action :set_appellation, only: [:show, :edit, :update, :destroy]

  def index
    @appellations = Appellation.order(:id).page(params[:page])
  end

  def show
  end

  def new
    @appellation = Appellation.new
    @regions = Region.all.order(:name)
  end

  def edit
    @regions = Region.all.order(:name)
  end

  def create
    @appellation = Appellation.new(appellation_params)

    if @appellation.save
      redirect_to admin_appellation_path(@appellation), notice: 'Appellation was successfully created.'
    else
      @regions = Region.all.order(:name)
      flash.now[:error] = @appellation.errors.full_messages.join(', ')
      render :new
    end
  end

  def update
    if @appellation.update(appellation_params)
      redirect_to admin_appellation_path(@appellation), notice: 'Appellation was successfully updated.'
    else
      @regions = Region.all.order(:name)
      flash.now[:error] = @appellation.errors.full_messages.join(', ')
      render :edit
    end
  end

  def destroy
    @appellation.destroy

    redirect_to admin_appellations_url, notice: 'Appellation was successfully destroyed.'
  end

  def import
    results = import_data(params[:file], :appellations, %w(appellation_id name classification region_id))

    if results[:success]
      respond_to do |format|
        format.html { redirect_to admin_appellations_path, notice: 'Appellation were successfully uploaded.' }
      end
    else
      respond_to do |format|
        format.html { redirect_to upload_admin_appellations_path, alert: results[:errors].join(', ') }
      end
    end
  end


  private

  def set_appellation
    @appellation = Appellation.find(params[:id])
  end

  def appellation_params
    params.require(:appellation).permit(:name, :classification, :region_id)
  end

end
