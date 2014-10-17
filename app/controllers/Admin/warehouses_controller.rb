class Admin::WarehousesController < ApplicationController
  layout "admin"
  before_action :authenticate_user!
  authorize_actions_for SupplierAuthorizer # Triggers user check
  before_action :set_warehouse, only: [:show, :edit, :update, :destroy]

  # GET /warehouses
  # GET /warehouses.json
  def index
    @warehouses = Warehouse.all
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
    @warehouse.shutl = create_shutl

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

  # PATCH/PUT /warehouses/1
  # PATCH/PUT /warehouses/1.json
  def update
    # respond_to do |format|
      if update_shutl == false
        redirect_to edit_admin_warehouse_url, :flash => { :notice => "Shutl did not update!" }
      else
        if @warehouse.update(warehouse_params)
          format.html { redirect_to [:admin, @warehouse], notice: 'Warehouse was successfully updated.' }
          format.json { render :show, status: :ok, location: @warehouse }
        else
          format.html { render :edit }
          format.json { render json: @warehouse.errors, status: :unprocessable_entity }
        end
      end
    # end
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
        address_attributes: [:id, :detail, :street, :postcode],
        agendas_attributes: [:id, :day, :opening, :closing]
      )
    end

    # ----------------------------------------------
    # Shutl methods

    def shutl_url
      "https://sandbox-v2.shutl.co.uk"
    end

    def shutl_id
      "HnnFB2UbMlBXdD9h4UzKVQ=="
      # "UOuPfVIAvP4BJWDmXdCiSw=="
    end

    def shutl_secret
      "pKNKPPCejzviiPunGNhnJ95G1JdeAbOYbyAygqIXyfIe4lb73iIDKRqmeZmZWT+ORxTqwMP9PhscJAW7GFmz6A=="
      # "DAiXY/UzTM14g6PAqAHDrm/ILwkJ3fT5mnh7aT15JiPI6YLz5GYN7qLtx4Yac60PFN+rZRuZuFyi0FExri3F6w=="
    end

    def shutl_token
      require 'net/http'
      require 'json'
      domain = shutl_url
      shutlId = shutl_id
      shutlSecret = shutl_secret
      url = URI("#{domain}/token")
      params = {
        'client_id' => shutlId,
        'client_secret' => shutlSecret,
        'grant_type' => 'client_credentials'
      }
      headers = {
        'Content-Type' => 'application/x-www-form-urlencoded'
      }
      reqToken = Net::HTTP::Post.new(url, headers)
      reqToken.form_data = params
      connection = Net::HTTP::start(url.hostname, url.port, :use_ssl => true ) {|http|
        http.request(reqToken)
      }
      response = JSON.parse(connection.read_body)
      response['access_token']
    end

    # GET /stores

    # POST /stores
    def create_shutl
      puts 'Adding warehouse to shutl'
      require 'net/http'
      require 'json'
      domain = shutl_url
      url = URI("#{domain}/stores")
      token = shutl_token
      
      # phoneNumber = @warehouse.phone.to_i.to_s #removes leading zero
      
      agendas = []
      @warehouse.agendas.each do |agenda|
        if agenda.opening == 0 && agenda.closing == 0
          agendas[agenda.day] = []
        else
          agendas[agenda.day] = [[agenda.shutl_opening, agenda.shutl_closing]]
        end
      end

      headers = {
        'Authorization' => "Bearer #{token}"
      }
      body = {
          :store => {
              :brand_name => @warehouse.title,
              :id => @warehouse.shutl_id,
              :name => "#{@warehouse.title} #{@warehouse.address.postcode}",
              :address_line_1 => @warehouse.address.line,
              :address_line_2 => "",
              :city => "London",
              # :county_or_state => nil,
              :country => "GB",
              :postcode => @warehouse.address.postcode,
              :phone_number => @warehouse.phone,
              :email => @warehouse.email,
              :send_confirmation_email => true,
              :send_confirmation_sms => false,
              :send_store_tracking_email => false,
              :sms_phone_number => "",
              :delay_time => 0,
              :time_zone => "Europe/London",
              :opening_hours => {
                  :monday    => agendas[1],
                  :tuesday   => agendas[2],
                  :wednesday => agendas[3],
                  :thursday  => agendas[4],
                  :friday    => agendas[5],
                  :saturday  => agendas[6],
                  :sunday    => agendas[0]
              }
          }
      }
      puts body.to_json
      req = Net::HTTP::Post.new(url, headers)
      req.body = body.to_json
      connection = Net::HTTP::start(url.hostname, url.port, :use_ssl => true ) {|http|
        http.request(req)
      }
      response = JSON.parse(connection.read_body)
      puts "================================************"
      puts response

# {"errors"=>{"opening_hours"=>["Invalid entry. Multiple opening hours should be comma separated and overlap between opening periods is not allowed"]}}

      if response["errors"]
        # @errors = response["errors"]
        return false
      else
        return true
      end
    end

    # PUT /stores/:id
    def update_shutl
      puts 'Updating warehouse in shutl'
      require 'net/http'
      require 'json'
      domain = shutl_url
      url = URI("#{domain}/stores")
      token = shutl_token
      
      # phoneNumber = @warehouse.phone.to_i.to_s #removes leading zero
      
      agendas = []
      @warehouse.agendas.each do |agenda|
        if agenda.opening == 0 && agenda.closing == 0
          agendas[agenda.day] = []
        else
          agendas[agenda.day] = [[agenda.shutl_opening, agenda.shutl_closing]]
        end
      end

      headers = {
        'Authorization' => "Bearer #{token}"
      }
      body = {
          :store => {
              :brand_name => @warehouse.title,
              :id => @warehouse.shutl_id,
              :name => "#{@warehouse.title}",
              :address_line_1 => @warehouse.address.line,
              :postcode => @warehouse.address.postcode,
              :phone_number => @warehouse.phone,
              :email => @warehouse.email,
              :opening_hours => {
                  :monday    => agendas[1],
                  :tuesday   => agendas[2],
                  :wednesday => agendas[3],
                  :thursday  => agendas[4],
                  :friday    => agendas[5],
                  :saturday  => agendas[6],
                  :sunday    => agendas[0]
              }
          }
      }
      puts body.to_json
      req = Net::HTTP::Put.new(url, headers)
      req.body = body.to_json
      connection = Net::HTTP::start(url.hostname, url.port, :use_ssl => true ) {|http|
        http.request(req)
      }
      response = JSON.parse(connection.read_body)
      puts "================================************"
      puts response

      if response["errors"]
        return false
      else
        return true
      end
    end

    # def destroy_shutl(name)
    # end

end
