class Admin::BottlingsController < ApplicationController
  layout "admin"
  before_action :authenticate_user!
  authorize_actions_for SupplierAuthorizer # Triggers user check
  before_action :set_bottling, only: [:show, :edit, :update, :destroy]

  # GET /bottlings
  # GET /bottlings.json
  def index
    @bottlings = Bottling.all
  end

  # GET /bottlings/1
  # GET /bottlings/1.json
  def show
  end

  # GET /bottlings/new
  def new
    @bottling = Bottling.new
  end

  # GET /bottlings/1/edit
  def edit
  end

  # POST /bottlings
  # POST /bottlings.json
  def create
    @bottling = Bottling.new(bottling_params)

    respond_to do |format|
      if @bottling.save
        format.html { redirect_to [:admin, @bottling], notice: 'Bottling was successfully created.' }
        format.json { render :show, status: :created, location: @bottling }
      else
        format.html { render :new }
        format.json { render json: @bottling.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bottlings/1
  # PATCH/PUT /bottlings/1.json
  def update
    respond_to do |format|
      if @bottling.update(bottling_params)
        format.html { redirect_to [:admin, @bottling], notice: 'Bottling was successfully updated.' }
        format.json { render :show, status: :ok, location: @bottling }
      else
        format.html { render :edit }
        format.json { render json: @bottling.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bottlings/1
  # DELETE /bottlings/1.json
  def destroy
    @bottling.destroy
    respond_to do |format|
      format.html { redirect_to admin_bottlings_url, notice: 'Bottling was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bottling
      @bottling = Bottling.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bottling_params
      params.require(:bottling).permit(:name)
    end
end
