class Admin::WinesController < ApplicationController
  include WineImporter

  layout "admin"
  before_filter :authenticate_user!
  before_action :set_wine, only: [:show, :edit, :update, :destroy]

  # GET /wines
  # GET /wines.json
  def index
    @wines = Wine.order(:id).page(params[:page])
  end

  # GET /wines/1
  # GET /wines/1.json
  def show
  end

  # GET /wines/new
  def new
    @wine = Wine.new
    fetch_data
  end

  # GET /wines/1/edit
  def edit
    fetch_data
  end

  # POST /wines
  # POST /wines.json
  def create

    puts json: params[:wine]

    # Validating
    if params[:wine][:name].empty? || params[:wine][:vintage].empty? || params[:wine][:producer_id].empty? ||
        params[:wine][:type_id].empty?
      fetch_data
      flash.now[:alert] = 'Wine cannot be saved, please fill name, vintage and producer'
      render :new
    else

      @wine = Wine.new

      @wine.name = params[:wine][:name]
      @wine.vintage = params[:wine][:vintage]
      @wine.single_estate = params[:wine][:single_estate]
      @wine.alcohol = params[:wine][:alcohol]
      @wine.producer_id = params[:wine][:producer_id]
      @wine.region_id = params[:wine][:region_id]
      @wine.subregion_id = params[:wine][:subregion_id]
      @wine.locale_id = params[:wine][:locale_id]
      @wine.appellation_id = params[:wine][:appellation_id]
      @wine.maturation_id = params[:wine][:maturation_id]
      @wine.type_id = params[:wine][:type_id]
      @wine.vinification_id = params[:wine][:vinification_id]
      @wine.composition_id = params[:wine][:composition_id]
      @wine.note = params[:wine][:note]
      @wine.bottle_size = params[:wine][:bottle_size]

      @wine.wine_key = create_wine_key_from_wine(@wine)

      if @wine.save
        respond_to do |format|
          format.html { redirect_to [:admin, @wine], notice: 'Wine was successfully created.' }
        end
      else
        fetch_data
        flash.now[:alert] = @wine.errors.full_messages.join(', ')
        render :new
      end
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

  # PATCH/PUT /wines/1
  # PATCH/PUT /wines/1.json
  def update
    respond_to do |format|
      if @wine.update(wine_params)
        format.html { redirect_to [:admin, @wine], notice: 'Wine was successfully updated.' }
        format.json { render :show, status: :ok, location: @wine }
      else
        format.html { render :edit }
        format.json { render json: @wine.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wines/1
  # DELETE /wines/1.json
  def destroy
    @wine.destroy
    respond_to do |format|
      format.html { redirect_to admin_wines_url, notice: 'Wine was successfully destroyed.' }
      format.json { head :no_content }
    end
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

    import_wines(file_path.to_s)

    respond_to do |format|
      format.html { redirect_to admin_wines_path, notice: 'Wines were successfully uploaded.' }
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
