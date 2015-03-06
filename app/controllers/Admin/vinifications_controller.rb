class Admin::VinificationsController < ApplicationController
  include GenericImporter
  layout "admin"
  before_action :authenticate_user!
  authorize_actions_for AdminAuthorizer # Triggers user check
  before_action :set_vinification, only: [:show, :edit, :update, :destroy]

  # GET /vinifications
  # GET /vinifications.json
  def index
    @vinifications = Vinification.all.order(:id)
  end

  # GET /vinifications/1
  # GET /vinifications/1.json
  def show
  end

  # GET /vinifications/new
  def new
    @vinification = Vinification.new
  end

  # GET /vinifications/1/edit
  def edit

  end

  # POST /vinifications
  # POST /vinifications.json
  def create
    @vinification = Vinification.new(vinification_params)
    respond_to do |format|
      if @vinification.save
        format.html { redirect_to [:admin, @vinification], notice: 'Vinification was successfully created.' }
        format.json { render :show, status: :created, location: @vinification }
      else
        format.html { render :new }
        format.json { render json: @vinification.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vinifications/1
  # PATCH/PUT /vinifications/1.json
  def update
    respond_to do |format|
      if @vinification.update(vinification_params)
        format.html { redirect_to [:admin, @vinification], notice: 'Vinification was successfully updated.' }
        format.json { render :show, status: :ok, location: @vinification }
      else
        format.html { render :edit }
        format.json { render json: @vinification.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vinifications/1
  # DELETE /vinifications/1.json
  def destroy
    @vinification.destroy
    respond_to do |format|
      format.html { redirect_to admin_vinifications_url, notice: 'Vinification was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def import
    results = import_data(params[:file], :vinifications, %w(vinification_id method name))

    if results[:success]
      respond_to do |format|
        format.html { redirect_to admin_vinifications_path, notice: 'Vinifications were successfully uploaded.' }
      end
    else
      respond_to do |format|
        format.html { redirect_to upload_admin_vinifications_path, alert: results[:errors].join(', ') }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vinification
      @vinification = Vinification.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vinification_params
      params.require(:vinification).permit(:bottling_id, :period)
    end
end
