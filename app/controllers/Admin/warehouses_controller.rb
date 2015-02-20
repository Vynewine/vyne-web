require 'json'

class Admin::WarehousesController < ApplicationController
  include ShutlHelper

  layout "admin"
  before_action :authenticate_user!
  authorize_actions_for SupplierAuthorizer # Triggers user check
  before_action :set_warehouse, only: [:show, :edit, :update, :destroy]
  authority_actions :shutl => 'read'

  # GET /warehouses
  # GET /warehouses.json
  def index
    @warehouses = Warehouse.all.order('active desc, id')
  end

  # GET /warehouses/1
  # GET /warehouses/1.json
  def show
    @agendas = @warehouse.agendas.order('day ASC')
  end

  # GET /warehouses/new
  def new
    @warehouse = Warehouse.new
    @warehouse.address = Address.new
    set_default_agenda(@warehouse)
  end

  # GET /warehouses/1/edit
  def edit
    data_for_edit
  end

  # POST /warehouses
  # POST /warehouses.json
  def create
    @warehouse = Warehouse.new(warehouse_params)

    unless @warehouse.save
      redirect_to new_admin_warehouse_path, alert: @warehouse.errors.full_messages().join(', ')
      return
    end

    if params[:update_shutl] == '1'
      response = add_warehouse_to_shutl(@warehouse)
    else
      response = {}
    end

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

    delivery_area = params[:warehouse][:delivery_area]

    @warehouse.area = delivery_area

    unless @warehouse.save
      redirect_to edit_admin_warehouse_path(@warehouse), alert: @warehouse.errors.full_messages().join(', ')
      return
    end

    if params[:update_shutl] == '1'
      if @warehouse.registered_with_shutl
        response = update_shutl_warehouse(@warehouse)
      else
        response = add_warehouse_to_shutl(@warehouse)
      end
      @warehouse.registered_with_shutl = true
    else
      response = {}
    end

    unless params[:user_id].blank?
      @warehouse.users << User.find(params[:user_id])
    end

    if response[:errors].blank?
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

  def remove_user
    @warehouse = Warehouse.find(params[:warehouse_id])
    user = User.find_by_id(params[:user_id])
    unless user.blank?
      @warehouse.users.delete(user)
    end
    redirect_to edit_admin_warehouse_path(@warehouse)
  end

  def shutl
    @warehouse = Warehouse.find(params[:warehouse_id])
    if @warehouse.registered_with_shutl
      shutl_info = get_warehouse_info_from_shutl(@warehouse)
      if shutl_info[:errors].blank?
        @shutl_info = shutl_info[:data].to_json
      else
        @shutl_info = shutl_info[:errors].join(', ')
      end
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
        agendas_attributes: [:id, :day, :opening, :closing, :opens_today,
                             :delivery_slots_from, :delivery_slots_to, :live_delivery_from, :live_delivery_to]
    )
  end

  def set_default_agenda(warehouse)
    if warehouse.agendas.count == 0
      (0..6).each { |i|
        Agenda.create(
            :warehouse_id => warehouse.id,
            :day => i,
            :opening => 900,
            :closing => 1800
        )
      }
    end
  end

  def data_for_edit
    @agendas = @warehouse.agendas.order('day ASC')
    if @warehouse.address.blank?
      @warehouse.address = Address.new
    end

    if @warehouse.agendas.blank?
      set_default_agenda(@warehouse)
    end

    @users = User.with_role(:supplier)
  end

end
