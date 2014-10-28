class Admin::WinesController < ApplicationController
  include WineImporter
  layout "admin"
  before_filter :authenticate_user!
  before_action :set_wine, only: [:show, :edit, :update, :destroy]

  # GET /wines
  # GET /wines.json
  def index
    @wines = Wine.all.order(:name)
  end

  # GET /wines/1
  # GET /wines/1.json
  def show
  end

  # GET /wines/new
  def new
    @wine = Wine.new
    @producers = Producer.all
    @subregions = Subregion.all
    @appellations = Appellation.all
    @types = Type.all
    # @wine.occasions.build
    # @occasion.wine.build
    # 3.times { @wine.compositions.build }
    @wine.compositions.build
    # @compositions = @wine.compositions
  end

  # GET /wines/1/edit
  def edit
    @producers = Producer.all
    @subregions = Subregion.all
    @appellations = Appellation.all
    @types = Type.all
    # @grapes = Grape.all
    @occasions = Occasion.all
    @foods = Food.all
    @notes = Note.all
    @allergies = Allergy.all
    @maturations = Maturation.all
    # 3.times { @wine.occasions.build }
    @compositions = @wine.compositions
  end

  # POST /wines
  # POST /wines.json
  def create
    require 'pp'
    puts '--------------------------'
    logger.warn "Save request"
    puts PP.pp(params,'',80)
    puts '--------------------------'
    # puts PP.pp(wine_params,'',80)
    

      # format.json { render json: @wine.errors, status: :unprocessable_entity }

    # else

      producer = Producer.find_by(:id => params[:wine][:producer_id].to_i)

      @wine = Wine.new

      @wine.name           = params[:wine][:name]
      @wine.vintage        = params[:wine][:vintage]
      @wine.area           = params[:wine][:area]
      @wine.single_estate  = params[:wine][:single_estate]
      @wine.alcohol        = params[:wine][:alcohol]
      @wine.sugar          = params[:wine][:sugar]
      @wine.acidity        = params[:wine][:acidity]
      @wine.ph             = params[:wine][:ph]
      @wine.vegan          = params[:wine][:vegan]
      @wine.organic        = params[:wine][:organic]
      @wine.producer       = producer
      @wine.subregion_id   = params[:wine][:subregion_id]
      @wine.appellation_id = params[:wine][:appellation_id]

      puts PP.pp(@wine,'',80)

      # Maturation
      maturation = params[:wine][:maturations_attributes]
      unless maturation.nil? || maturation[:bottling][:name].empty?
        currentBottling = Bottling.find_by(:name => maturation[:bottling][:name])
        if currentBottling.nil?
          puts "must add bottling to DB"
          currentBottling = Bottling.create(:name => maturation[:bottling][:name])
        else
          puts "Bottling's id is #{currentBottling.id}"
        end
        currentMaturation = Maturation.find_by(:bottling_id => currentBottling.id, :period => maturation[:period])
        if currentMaturation.nil?
          currentMaturation = Maturation.create(:bottling_id => currentBottling.id, :period => maturation[:period])
        end
        @wine.maturation = currentMaturation
      end

      # Validating
      if params[:wine][:name].empty? || params[:wine][:vintage].empty? || params[:wine][:producer_id].empty?
        @producers = Producer.all
        @subregions = Subregion.all
        @appellations = Appellation.all
        @types = Type.all
        @wine.compositions.build
        flash.now[:notice] = "Wine cannot be saved, please fill all the fields"
        render :new
      else
        if @wine.save
          # Composition
          composition = params[:wine][:compositions_attributes]
          unless composition.nil?
            composition.each do |c|
              currentGrape = Grape.find_by(:name => c[1][:grape])
              if currentGrape.nil?
                puts "must add grape to DB"
                currentGrape = Grape.create(:name => c[1][:grape])
              else
                puts "Grape's id is #{currentGrape.id}"
              end
              currentComposition = Composition.create(:grape_id => currentGrape.id, :quantity => c[1][:quantity], :wine_id => @wine.id)
              # currentComposition = Composition.where(:grape_id = currentGrape.id, :quantity => c[1][:quantity], :wine_id => @wine.id)
              # if currentComposition.nil?
              #   puts "adding composition"
              # else
              #   puts "composition's fine"
              # end
              # c[1][:quantity]
            end
          end

          # Types
          types = params[:wine][:type_ids]
          unless types.nil?
            types.each do |t|
              currentType = Type.find(t.to_i)
              TypesWines.create(:type => currentType, :wine => @wine)
            end
          end
        end
        redirect_to [:admin, @wine]
      end
    # @wine = Wine.new(wine_params)
    # params[:wine][:type_ids] ||= []
    # respond_to do |format|
    #   if @wine.save
    #     format.html { redirect_to [:admin, @wine], notice: 'Wine was successfully created.' }
    #     format.json { render :show, status: :created, location: @wine }
    #   else
    #     format.html { render :new }
    #     format.json { render json: @wine.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PATCH/PUT /wines/1
  # PATCH/PUT /wines/1.json
  def update
    params[:wine][:type_ids] ||= []
puts "-------------------------------"
puts params[:wine][:producer_id]
puts "-------------------------------"
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

    file_path = Rails.root.join('public', 'uploads', [Time.now.strftime('%Y-%m-%d-%H%M%S'),file_name].join('_'))

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
        :area,
        :single_estate,
        :alcohol,
        :sugar,
        :acidity,
        :ph,
        :vegan,
        :organic,
        :producer_id,
        :subregion_id,
        :appellation_id,
        :occasion_tokens,
        :food_tokens,
        :note_tokens,
        type_ids: [],
        occasions_attributes: [:name],
        :compositions_attributes => [:id, :grape_id, :quantity]
      )
      # params.require(:wine).permit()
    end
end
