class MaturationTypesController < ApplicationController
  before_action :set_maturation_type, only: [:show, :edit, :update, :destroy]

  # GET /maturation_types
  # GET /maturation_types.json
  def index
    @maturation_types = MaturationType.all
  end

  # GET /maturation_types/1
  # GET /maturation_types/1.json
  def show
  end

  # GET /maturation_types/new
  def new
    @maturation_type = MaturationType.new
  end

  # GET /maturation_types/1/edit
  def edit
  end

  # POST /maturation_types
  # POST /maturation_types.json
  def create
    @maturation_type = MaturationType.new(maturation_type_params)

    respond_to do |format|
      if @maturation_type.save
        format.html { redirect_to @maturation_type, notice: 'Maturation type was successfully created.' }
        format.json { render :show, status: :created, location: @maturation_type }
      else
        format.html { render :new }
        format.json { render json: @maturation_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /maturation_types/1
  # PATCH/PUT /maturation_types/1.json
  def update
    respond_to do |format|
      if @maturation_type.update(maturation_type_params)
        format.html { redirect_to @maturation_type, notice: 'Maturation type was successfully updated.' }
        format.json { render :show, status: :ok, location: @maturation_type }
      else
        format.html { render :edit }
        format.json { render json: @maturation_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /maturation_types/1
  # DELETE /maturation_types/1.json
  def destroy
    @maturation_type.destroy
    respond_to do |format|
      format.html { redirect_to maturation_types_url, notice: 'Maturation type was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_maturation_type
      @maturation_type = MaturationType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def maturation_type_params
      params.require(:maturation_type).permit(:name)
    end
end
