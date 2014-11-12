class Admin::WarehousesController < ApplicationController
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
  end

  # GET /warehouses/new
  def new
    @warehouse = Warehouse.new
    @warehouse.build_address
  end

  # GET /warehouses/1/edit
  def edit
    @agendas = @warehouse.agendas.order('day ASC')
  end

  # POST /warehouses
  # POST /warehouses.json
  def create
    @warehouse = Warehouse.new(warehouse_params)

    respond_to do |format|
      if @warehouse.save
        format.html { redirect_to [:admin, @warehouse], notice: 'Warehouse was successfully created.' }
        format.json { render :show, status: :created, location: @warehouse }
      else
        format.html {
          @warehouse.build_address
          render :new
        }
        format.json { render json: @warehouse.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
      @warehouse.update_attributes(warehouse_params)
        respond_to do |format|
          if @warehouse.update(warehouse_params)
            format.html { redirect_to [:admin, @warehouse], notice: 'Warehouse was successfully updated.' }
            format.json { render :show, status: :ok, location: @warehouse }
          else
            format.html { render :edit }
            format.json { render json: @warehouse.errors, status: :unprocessable_entity }
          end
        end
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
        address_attributes: [:id, :detail, :street, :postcode],
        agendas_attributes: [:id, :day, :opening, :closing]
      )
    end

end
