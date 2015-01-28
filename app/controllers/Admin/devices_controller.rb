class Admin::DevicesController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!
  authorize_actions_for AdminAuthorizer, :except => :register
  authority_actions :register => 'update'


  def index
    @devices = Device.all.order(:id)
  end

  def new
    @device = Device.new
    @device.key = Device.generate_key
    @warehouses = Warehouse.all.order(:id)
  end

  def show
    @device = Device.find(params[:id])
  end

  def edit
    @device = Device.find(params[:id])
    @warehouses = Warehouse.all.order(:id)
  end

  def create
    @device = Device.new(device_params)

    unless params[:device][:warehouse_id].blank?
      warehouse = Warehouse.find_by_id(params[:device][:warehouse_id])
      unless warehouse.blank?
        @device.warehouse = warehouse
      end
    end

    respond_to do |format|
      if @device.save
        format.html { redirect_to [:admin, @device], notice: 'Device was successfully created.' }
        format.json { render :show, status: :created, location: @device }
      else
        format.html { render :new }
        format.json { render json: @device.errors, status: :unprocessable_entity }
      end
    end
  end

  def update

    @device = Device.find(params[:id])

    unless params[:device][:warehouse_id].blank?
      warehouse = Warehouse.find_by_id(params[:device][:warehouse_id])
      unless warehouse.blank?
        @device.warehouse = warehouse
      end
    end

    respond_to do |format|
      if @device.update(device_params)
        format.html { redirect_to [:admin, @device], notice: 'Device was successfully updated.' }
        format.json { render :show, status: :ok, location: @device }
      else
        format.html { render :edit }
        format.json { render json: @device.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @device = Device.find(params[:id])
    @device.destroy
    respond_to do |format|
      format.html { redirect_to admin_devices_url, notice: 'Device was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def register
    unless (current_user.has_role? :supplier) || (current_user.has_role? :admin)
      return head :forbidden
    end

    @device = Device.find_by_key(params[:key])

    if @device.blank?
      render json: ['Device not found'], status: :unprocessable_entity
    else
      @device.registration_id = params[:registration_id]
      if @device.save
        render json: @device, status: :ok
        return
      else
        render json: @device.errors, status: :unprocessable_entity
        return
      end
    end
  end

  private

  def device_params
    params.require(:device).permit(:key)
  end
end
