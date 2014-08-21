class MaturationsController < ApplicationController
  before_action :set_maturation, only: [:show, :edit, :update, :destroy]

  # GET /maturations
  # GET /maturations.json
  def index
    @maturations = Maturation.all
  end

  # GET /maturations/1
  # GET /maturations/1.json
  def show
  end

  # GET /maturations/new
  def new
    @maturation = Maturation.new
    @bottlings = Bottling.all
  end

  # GET /maturations/1/edit
  def edit
    @bottlings = Bottling.all
  end

  # POST /maturations
  # POST /maturations.json
  def create
    @maturation = Maturation.new(maturation_params)
    @maturation.bottling = Bottling.find( params[ :bottling_id ] )
    respond_to do |format|
      if @maturation.save
        format.html { redirect_to @maturation, notice: 'Maturation was successfully created.' }
        format.json { render :show, status: :created, location: @maturation }
      else
        format.html { render :new }
        format.json { render json: @maturation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /maturations/1
  # PATCH/PUT /maturations/1.json
  def update
    @maturation.bottling = Bottling.find( params[ :bottling_id ] )
    respond_to do |format|
      if @maturation.update(maturation_params)
        format.html { redirect_to @maturation, notice: 'Maturation was successfully updated.' }
        format.json { render :show, status: :ok, location: @maturation }
      else
        format.html { render :edit }
        format.json { render json: @maturation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /maturations/1
  # DELETE /maturations/1.json
  def destroy
    @maturation.destroy
    respond_to do |format|
      format.html { redirect_to maturations_url, notice: 'Maturation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_maturation
      @maturation = Maturation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def maturation_params
      params.require(:maturation).permit(:bottling_id, :period)
    end
end
