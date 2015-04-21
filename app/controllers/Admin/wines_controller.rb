class Admin::WinesController < ApplicationController
  include WineImporter

  layout 'admin'
  before_filter :authenticate_user!
  authorize_actions_for AdminAuthorizer
  before_action :set_wine, only: [:show, :edit, :update, :destroy]

  def index
    @wines = Wine.order(:id).page(params[:page])
  end

  def show
  end

  def new
    @wine = Wine.new
    fetch_data
  end

  def edit
    fetch_data
  end

  def create

      @wine = Wine.new(wine_params)

      unless @wine.valid?
        fetch_data
        flash.now[:alert] = @wine.errors.full_messages.join(', ')
        render :new
        return
      end

      if params[:wine][:wine_key].blank?
        @wine.wine_key = WineImporter.create_wine_key_from_wine(@wine)
      else
        @wine.wine_key = params[:wine][:wine_key]
      end

      if @wine.save
        redirect_to admin_wine_path(@wine), notice: 'Wine was successfully created.'

        Resque.enqueue(InventoryReIndexing, [@wine.id])

      else
        fetch_data
        flash.now[:alert] = @wine.errors.full_messages.join(', ')
        render :new
      end
  end

  def fetch_data
    @producers = Producer.all.order(:name)
    @regions = Region.all.order(:name)
    @subregions = Subregion.all.order(:name)
    @locales = Locale.all.order(:name)
    @appellations = Appellation.all.order(:name)
    @types = Type.all.order(:name)
    @compositions = Composition.all.order(:id)
    @maturations = Maturation.all.order(:id)
    @vinifications = Vinification.all.order(:id)
  end

  def update

    if params[:wine][:wine_key].blank?
      @wine.wine_key = WineImporter.create_wine_key_from_wine(@wine)
    else
      @wine.wine_key = params[:wine][:wine_key]
    end

    if @wine.update(wine_params)

      Resque.enqueue(InventoryReIndexing, [@wine.id])

      redirect_to [:admin, @wine], notice: 'Wine was successfully updated.'
    else
      flash.now[:error] = @wine.errors.full_messages.join(', ')
      fetch_data
      render :edit
    end

  end

  def destroy
    @wine.wine_key = "#{@wine.wine_key}-retired-#{@wine.id}"
    @wine.save
    @wine.destroy

    redirect_to admin_wines_url, notice: 'Wine was successfully destroyed.'
  end

  def upload
  end

  def import
    uploaded_file = params[:wines]

    if uploaded_file.nil?
      respond_to do |format|
        format.html { redirect_to upload_admin_inventories_path, alert: 'Please specify file to upload.' }
      end
      return
    end

    file_name = uploaded_file.original_filename

    file_extension = File.extname(file_name)

    if file_extension != '.csv'
      respond_to do |format|
        format.html { redirect_to upload_admin_inventories_path, alert: 'File must be .csv format' }
      end
      return
    end

    file_path = Rails.root.join('public', 'uploads', [Time.now.strftime('%Y-%m-%d-%H%M%S'), file_name].join('_'))

    File.open(file_path, 'wb') do |file|
      file.write(uploaded_file.read)
    end

    results = WineImporter.import_wines(file_path.to_s)

    if results[:errors].blank?
      redirect_to admin_wines_path, notice: 'Wines were successfully uploaded.'
    else
      redirect_to admin_wines_path, :flash => {:error => results[:errors].join(', ')}
    end

  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_wine
    @wine = Wine.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def wine_params
    params.require(:wine).permit(
        :name,
        :vintage,
        :single_estate,
        :alcohol,
        :producer_id,
        :region_id,
        :subregion_id,
        :locale_id,
        :appellation_id,
        :maturation_id,
        :type_id,
        :composition_id,
        :vinification_id,
        :note,
        :bottle_size,
        :id
    )
    # params.require(:wine).permit()
  end
end
