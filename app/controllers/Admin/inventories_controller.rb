class Admin::InventoriesController < ApplicationController
  include InventoryImporter

  layout "admin"
  before_action :authenticate_user!
  authorize_actions_for SupplierAuthorizer # Triggers user check
  before_action :set_inventory, only: [:show, :edit, :update, :destroy]

  # GET /inventories
  # GET /inventories.json
  def index
    @warehouses = Warehouse.all.order('active desc, id')

    unless current_user.admin?
      @warehouses = @warehouses.where(id: current_user.warehouses)
    end

    warehouse_id = params[:warehouse_id]

    unless current_user.admin?
      unless current_user.warehouses.map { |warehouse| warehouse.id.to_s }.include?(warehouse_id)
        warehouse_id = nil
      end
    end

    if warehouse_id.blank?
      @inventories = []
    else
      @inventories = Inventory
                         .joins(:warehouse, :wine)
                         .order('vendor_sku')
                         .where(:warehouse_id => params[:warehouse_id])
                         .page(params[:page])

      unless params[:search].blank?
        @inventories = @inventories.where(:vendor_sku => params[:search])
      end

      @warehouse = Warehouse.find(params[:warehouse_id])
    end
  end

  # GET /inventories/1
  # GET /inventories/1.json
  def show
  end

  # GET /inventories/new
  def new
    @inventory = Inventory.new
    fetch_data
  end

  def fetch_data
    @categories = Category.all
    @warehouses = Warehouse.all.order(:id)
    unless current_user.admin?
      @warehouses = @warehouses.where(id: current_user.warehouses)
    end
  end

  # GET /inventories/1/edit
  def edit
    @inventory = Inventory.find(params[:id])
    fetch_data
  end

  # POST /inventories
  # POST /inventories.json
  def create

    if params[:inventory][:warehouse_id].empty? || params[:inventory][:wine_id].empty? || params[:inventory][:vendor_sku].empty? ||
        params[:inventory][:category_id].empty?
      @inventory = Inventory.new
      fetch_data
      flash.now[:error] = 'Warehouse, wine, vendor sku and category are required'
      render :new
      return
    end

    @inventory = Inventory.new(inventory_params)

    respond_to do |format|
      if @inventory.save

        Sunspot.index! [@inventory.wine]

        format.html { redirect_to [:admin, @inventory], notice: 'Inventory was successfully created.' }
        format.json { render :show, status: :created, location: @inventory }
      else
        fetch_data
        flash.now[:error] =  @inventory.errors.full_messages().join(', ')
        format.html { render :new }
        format.json { render json: @inventory.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /inventories/1
  # PATCH/PUT /inventories/1.json
  def update
    respond_to do |format|
      if @inventory.update(inventory_params)

        Sunspot.index! [@inventory.wine]

        format.html { redirect_to [:admin, @inventory], notice: 'Inventory was successfully updated.' }
        format.json { render :show, status: :ok, location: @inventory }
      else
        format.html { render :edit }
        format.json { render json: @inventory.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /inventories/1
  # DELETE /inventories/1.json
  def destroy
    wine = @inventory.wine

    @inventory.destroy

    Sunspot.index! [wine]

    respond_to do |format|
      format.html { redirect_to admin_inventories_url, notice: 'Inventory was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def upload
    @warehouses = Warehouse.all.order('active desc, id')
    unless current_user.admin?
      @warehouses = @warehouses.where(id: current_user.warehouses)
    end
  end

  def import

    uploaded_file = params[:inventory]

    if uploaded_file.nil? || params[:warehouse].blank?
      respond_to do |format|
        format.html { redirect_to upload_admin_inventories_path, alert: 'Please select Warehouse and file to upload.' }
      end
      return
    end

    warehouse = Warehouse.find_by_id(params[:warehouse])

    if warehouse.nil?
      respond_to do |format|
        format.html { redirect_to upload_admin_inventories_path, alert: 'Warehouse Not Found' }
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

    results = InventoryImporter.import_inventory(file_path.to_s, warehouse)

    if results[:errors].blank?
      redirect_to admin_inventories_path, notice: 'Inventory was successfully uploaded.'
    else
      redirect_to admin_inventories_path, :flash => { :error => results[:errors] }
    end


  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_inventory
    @inventory = Inventory.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def inventory_params
    params.require(:inventory).permit(:warehouse_id, :wine_id, :quantity, :category_id, :cost, :vendor_sku)
  end
end
