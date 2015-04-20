class Admin::GrapesController < ApplicationController
  include GenericImporter
  layout 'admin'
  before_action :authenticate_user!
  authorize_actions_for AdminAuthorizer
  before_action :set_grape, only: [:show, :edit, :update, :destroy]

  def index
    @grapes = Grape.order(:id).page(params[:page])
  end

  def show
  end

  def new
    @grape = Grape.new
  end

  def edit
  end

  def create
    @grape = Grape.new(grape_params)

    if @grape.save
      redirect_to admin_grape_path(@grape), notice: 'Grape was successfully created.'
    else
      flash.now[:error] = @grape.errors.full_messages.join(', ')
      render :new
    end
  end

  def update
    if @grape.update(grape_params)
      redirect_to admin_grape_path(@grape), notice: 'Grape was successfully updated.'
    else
      flash.now[:error] = @grape.errors.full_messages.join(', ')
      render :edit
    end
  end

  def destroy
    @grape.destroy
    redirect_to admin_grapes_url, notice: 'Grape was successfully destroyed.'
  end

  def import
    results = import_data(params[:file], :grapes, %w(grape_id name))

    if results[:success]
      redirect_to admin_grapes_path, notice: 'Grapes were successfully uploaded.'
    else
      redirect_to upload_admin_grapes_path, alert: results[:errors].join(', ')
    end
  end

  private

  def set_grape
    @grape = Grape.find(params[:id])
  end

  def grape_params
    params.require(:grape).permit(:name)
  end

end
