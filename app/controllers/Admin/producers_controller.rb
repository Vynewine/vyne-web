class Admin::ProducersController < ApplicationController
  include GenericImporter
  layout "admin"
  before_action :authenticate_user!
  authorize_actions_for SupplierAuthorizer # Triggers user check
  before_action :set_producer, only: [:show, :edit, :update, :destroy]

  # GET /producers
  # GET /producers.json
  def index
    @producers = Producer.all.order(:id)
  end

  # GET /producers/1
  # GET /producers/1.json
  def show
  end

  # GET /producers/new
  def new
    @producer = Producer.new
    @countries = Country.all
  end

  # GET /producers/1/edit
  def edit
    @countries = Country.all
  end

  # POST /producers
  # POST /producers.json
  def create
    @producer = Producer.new(producer_params)
    @producer.country = Country.find( params[ :country ] )
    respond_to do |format|
      if @producer.save
        format.html { redirect_to [:admin, @producer], notice: 'Producer was successfully created.' }
        format.json { render :show, status: :created, location: @producer }
      else
        format.html { render :new }
        format.json { render json: @producer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /producers/1
  # PATCH/PUT /producers/1.json
  def update
    @producer.country = Country.find( params[ :country ] )
    respond_to do |format|
      if @producer.update(producer_params)
        format.html { redirect_to [:admin, @producer], notice: 'Producer was successfully updated.' }
        format.json { render :show, status: :ok, location: @producer }
      else
        format.html { render :edit }
        format.json { render json: @producer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /producers/1
  # DELETE /producers/1.json
  def destroy
    @producer.destroy
    respond_to do |format|
      format.html { redirect_to admin_producers_url, notice: 'Producer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def import
    results = import_data(params[:file], :producers, %w(producer_id name country_id note))

    if results[:success]
      respond_to do |format|
        format.html { redirect_to admin_producers_path, notice: 'Producers were successfully uploaded.' }
      end
    else
      respond_to do |format|
        format.html { redirect_to upload_admin_producers_path, alert: results[:errors].join(', ') }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_producer
      @producer = Producer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def producer_params
      params.require(:producer).permit(:name, :country)
    end
end
