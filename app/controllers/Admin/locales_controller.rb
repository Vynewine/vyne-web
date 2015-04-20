class Admin::LocalesController < ApplicationController
  include GenericImporter
  layout 'admin'
  before_action :authenticate_user!
  authorize_actions_for AdminAuthorizer
  before_action :set_locale, only: [:show, :edit, :update, :destroy]

  def index
    @locales = Locale.order(:id).page(params[:page])
  end

  def show
  end

  def new
    @locale = Locale.new
    @subregions = Subregion.all.order(:name)
  end

  def edit
    @subregions = Subregion.all.order(:name)
  end

  def create
    @locale = Locale.new(locale_params)

    if @locale.save
      redirect_to admin_locale_path(@locale), notice: 'Locale was successfully created.'
    else
      @subregions = Subregion.all.order(:name)
      flash.now[:error] = @locale.errors.full_messages.join(', ')
      render :new
    end
  end

  def update
    if @locale.update(locale_params)
      redirect_to admin_locale_path(@locale), notice: 'Locale was successfully updated.'
    else
      @subregions = Subregion.all.order(:name)
      flash.now[:error] = @locale.errors.full_messages.join(', ')
      render :edit
    end
  end

  def destroy
    @locale.destroy
    redirect_to admin_locales_url, notice: 'Locale was successfully destroyed.'
  end

  def import
    results = import_data(params[:file], :locales, %w(locale_id name subregion_id note))

    if results[:success]
      redirect_to admin_locales_path, notice: 'Locales were successfully uploaded.'
    else
      redirect_to upload_admin_locales_path, alert: results[:errors].join(', ')
    end
  end

  private

  def set_locale
    @locale = Locale.find(params[:id])
  end

  def locale_params
    params.require(:locale).permit(:name, :subregion_id, :note)
  end

end
