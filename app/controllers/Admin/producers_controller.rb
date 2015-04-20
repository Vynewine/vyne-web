class Admin::ProducersController < ApplicationController
  include GenericImporter
  layout 'admin'
  before_action :authenticate_user!
  authorize_actions_for AdminAuthorizer
  before_action :set_producer, only: [:show, :edit, :update, :destroy]

  def index
    @producers = Producer.order(:id).page(params[:page])
  end

  def show
  end

  def new
    @producer = Producer.new
    @countries = Country.all
  end

  def edit
    @countries = Country.all
  end

  def create
    @producer = Producer.new(producer_params)
    if @producer.save
      redirect_to [:admin, @producer], notice: 'Producer was successfully created.'
    else
      @countries = Country.all
      flash.now[:error] = @producer.errors.full_messages.join(', ')
      render :new
    end
  end

  def update
    if @producer.update(producer_params)
      redirect_to [:admin, @producer], notice: 'Producer was successfully updated.'
    else
      @countries = Country.all
      flash.now[:error] = @producer.errors.full_messages.join(', ')
      render :edit
    end
  end

  def destroy
    @producer.destroy
    redirect_to admin_producers_url, notice: 'Producer was successfully destroyed.'
  end

  def import

    results = import_data(params[:file], :producers, %w(producer_id name country_id note))

    if results[:success]
      redirect_to admin_producers_path, notice: 'Producers were successfully uploaded.'
    else
      redirect_to upload_admin_producers_path, alert: results[:errors].join(', ')
    end
  end

  private

  def set_producer
    @producer = Producer.find(params[:id])
  end

  def producer_params
    params.require(:producer).permit(:name, :country_id, :note)
  end

end
