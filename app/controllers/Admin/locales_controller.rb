class Admin::LocalesController < ApplicationController
  include GenericImporter
  layout "admin"
  before_action :authenticate_user!
  authorize_actions_for AdminAuthorizer # Triggers user check
  before_action :set_locale, only: [:show, :edit, :update, :destroy]

  # GET /locales
  # GET /locales.json
  def index
    @locales = Locale.all.order(:id)
  end

  # GET /locales/1
  # GET /locales/1.json
  def show
  end

  # GET /locales/new
  def new
    @locale = Locale.new
    @subregions = Region.all
  end

  # GET /locales/1/edit
  def edit
    @subregions = Region.all
  end

  # POST /locales
  # POST /locales.json
  def create
    @locale = Locale.new(locale_params)
    @locale.region = Region.find( params[ :subregion_id ] )
    respond_to do |format|
      if @locale.save
        format.html { redirect_to [:admin, @locale], notice: 'Locale was successfully created.' }
        format.json { render :show, status: :created, location: @locale }
      else
        format.html { render :new }
        format.json { render json: @locale.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /locales/1
  # PATCH/PUT /locales/1.json
  def update
    respond_to do |format|
      if @locale.update(locale_params)
        format.html { redirect_to [:admin, @locale], notice: 'Locale was successfully updated.' }
        format.json { render :show, status: :ok, location: @locale }
      else
        format.html { render :edit }
        format.json { render json: @locale.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /locales/1
  # DELETE /locales/1.json
  def destroy
    @locale.destroy
    respond_to do |format|
      format.html { redirect_to admin_locales_url, notice: 'Locale was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def import
    results = import_data(params[:file], :locales, %w(locale_id name subregion_id note))

    if results[:success]
      respond_to do |format|
        format.html { redirect_to admin_locales_path, notice: 'Locales were successfully uploaded.' }
      end
    else
      respond_to do |format|
        format.html { redirect_to upload_admin_locales_path, alert: results[:errors].join(', ') }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_locale
      @locale = Locale.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def locale_params
      params.require(:locale).permit(:name, :subregion_id, :note)
    end
end
