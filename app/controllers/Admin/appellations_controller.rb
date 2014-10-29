class Admin::AppellationsController < ApplicationController
  include GenericImporter
  layout "admin"
  before_action :authenticate_user!
  authorize_actions_for SupplierAuthorizer # Triggers user check
  before_action :set_appellation, only: [:show, :edit, :update, :destroy]

  # GET /appellations
  # GET /appellations.json
  def index
    @appellations = Appellation.all.order(:id)
  end

  # GET /appellations/1
  # GET /appellations/1.json
  def show
  end

  # GET /appellations/new
  def new
    @appellation = Appellation.new
  end

  # GET /appellations/1/edit
  def edit
  end

  # POST /appellations
  # POST /appellations.json
  def create
    @appellation = Appellation.new(appellation_params)

    respond_to do |format|
      if @appellation.save
        format.html { redirect_to [:admin, @appellation], notice: 'Appellation was successfully created.' }
        format.json { render :show, status: :created, location: @appellation }
      else
        format.html { render :new }
        format.json { render json: @appellation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /appellations/1
  # PATCH/PUT /appellations/1.json
  def update
    respond_to do |format|
      if @appellation.update(appellation_params)
        format.html { redirect_to [:admin, @appellation], notice: 'Appellation was successfully updated.' }
        format.json { render :show, status: :ok, location: @appellation }
      else
        format.html { render :edit }
        format.json { render json: @appellation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /appellations/1
  # DELETE /appellations/1.json
  def destroy
    @appellation.destroy
    respond_to do |format|
      format.html { redirect_to admin_appellations_url, notice: 'Appellation was successfully destroyed.' }
      format.json { head :no_content }
    end
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
    # Use callbacks to share common setup or constraints between actions.
    def set_appellation
      @appellation = Appellation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def appellation_params
      params.require(:appellation).permit(:name)
    end
end
