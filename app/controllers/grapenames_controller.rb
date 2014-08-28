class GrapenamesController < ApplicationController
  layout "admin"
  before_action :authenticate_user!
  authorize_actions_for SupplierAuthorizer # Triggers user check
  before_action :set_grapename, only: [:show, :edit, :update, :destroy]

  # GET /grapenames
  # GET /grapenames.json
  def index
    @grapenames = Grapename.all
  end

  # GET /grapenames/1
  # GET /grapenames/1.json
  def show
  end

  # GET /grapenames/new
  def new
    @grapename = Grapename.new
  end

  # GET /grapenames/1/edit
  def edit
  end

  # POST /grapenames
  # POST /grapenames.json
  def create
    @grapename = Grapename.new(grapename_params)

    respond_to do |format|
      if @grapename.save
        format.html { redirect_to @grapename, notice: 'Grapename was successfully created.' }
        format.json { render :show, status: :created, location: @grapename }
      else
        format.html { render :new }
        format.json { render json: @grapename.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /grapenames/1
  # PATCH/PUT /grapenames/1.json
  def update
    respond_to do |format|
      if @grapename.update(grapename_params)
        format.html { redirect_to @grapename, notice: 'Grapename was successfully updated.' }
        format.json { render :show, status: :ok, location: @grapename }
      else
        format.html { render :edit }
        format.json { render json: @grapename.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /grapenames/1
  # DELETE /grapenames/1.json
  def destroy
    @grapename.destroy
    respond_to do |format|
      format.html { redirect_to grapenames_url, notice: 'Grapename was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_grapename
      @grapename = Grapename.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def grapename_params
      params.require(:grapename).permit(:name)
    end
end
