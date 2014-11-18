class Admin::WarehousesController < ApplicationController
  include ShutlHelper

  layout "admin"
  before_action :authenticate_user!
  authorize_actions_for SupplierAuthorizer # Triggers user check
  before_action :set_warehouse, only: [:show, :edit, :update, :destroy]

  # GET /warehouses
  # GET /warehouses.json
  def index
    @warehouses = Warehouse.all.order('active desc, id')
  end

  # GET /warehouses/1
  # GET /warehouses/1.json
  def show
    @agendas = @warehouse.agendas.order('day ASC')
    if @warehouse.registered_with_shutl
      shutl_info = get_warehouse_info_from_shutl(@warehouse)
      if shutl_info[:errors].blank?
        @shutl_info = shutl_info[:data]
      else
        @shutl_info = shutl_info[:errors].join(', ')
      end
    end
  end

  # GET /warehouses/new
  def new
    @warehouse = Warehouse.new
    @warehouse.address = Address.new
  end

  # GET /warehouses/1/edit
  def edit
    @agendas = @warehouse.agendas.order('day ASC')
    if @warehouse.address.blank?
      @warehouse.address = Address.new
    end
  end

  # POST /warehouses
  # POST /warehouses.json
  def create
    @warehouse = Warehouse.new(warehouse_params)

    unless @warehouse.save
      redirect_to new_admin_warehouse_path, alert: @warehouse.errors.full_messages().join(', ')
      return
    end

    response = add_warehouse_to_shutl(@warehouse)

    if response[:errors].blank?
      @warehouse.registered_with_shutl = true
      unless @warehouse.save
        redirect_to new_admin_warehouse_path, alert: @warehouse.errors.full_messages().join(', ')
        return
      end
    else
      redirect_to edit_admin_warehouse_path(@warehouse), alert: response[:errors].join(', ')
      return
    end

    respond_to do |format|
      format.html { redirect_to [:admin, @warehouse], notice: 'Warehouse was successfully created.' }
      format.json { render :show, status: :created, location: @warehouse }
    end
  end

  def update
    @warehouse.update_attributes(warehouse_params)

    unless @warehouse.update(warehouse_params)
      redirect_to edit_admin_warehouse_path(@warehouse), alert: @warehouse.errors.full_messages().join(', ')
      return
    end

    if @warehouse.registered_with_shutl
      response = update_shutl_warehouse(@warehouse)
    else
      response = add_warehouse_to_shutl(@warehouse)
    end

    puts json: response

    if response[:errors].blank?
      @warehouse.registered_with_shutl = true
      unless @warehouse.save
        redirect_to edit_admin_warehouse_path(@warehouse), alert: @warehouse.errors.full_messages().join(', ')
        return
      end
    else
      redirect_to edit_admin_warehouse_path(@warehouse), alert: response[:errors].join(', ')
      return
    end

    redirect_to [:admin, @warehouse], notice: 'Warehouse was successfully updated.'

  end

  # DELETE /warehouses/1
  # DELETE /warehouses/1.json
  def destroy
    @warehouse.destroy
    respond_to do |format|
      format.html { redirect_to admin_warehouses_url, notice: 'Warehouse was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_warehouse
    @warehouse = Warehouse.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def warehouse_params
    params.require(:warehouse).permit(
        :title,
        :email,
        :phone,
        :active,
        address_attributes: [:id, :line_1, :postcode, :line_2, :company_name, :longitude, :latitude],
        agendas_attributes: [:id, :day, :opening, :closing]
    )
  end

end
