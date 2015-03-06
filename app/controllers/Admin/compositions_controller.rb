class Admin::CompositionsController < ApplicationController

  layout "admin"
  before_action :authenticate_user!
  authorize_actions_for AdminAuthorizer # Triggers user check
  before_action :set_composition, only: [:show, :edit, :update, :destroy]

  # GET /compositions
  # GET /compositions.json
  def index
    @compositions = Composition.all.order(:id)
  end

  # GET /compositions/1
  # GET /compositions/1.json
  def show
  end

  # GET /compositions/new
  def new
    @composition = Composition.new
  end

  # GET /compositions/1/edit
  def edit
  end

  # POST /compositions
  # POST /compositions.json
  def create
    @composition = Composition.new(composition_params)
    respond_to do |format|
      if @composition.save
        format.html { redirect_to [:admin, @composition], notice: 'Composition was successfully created.' }
        format.json { render :show, status: :created, location: @composition }
      else
        format.html { render :new }
        format.json { render json: @composition.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /compositions/1
  # PATCH/PUT /compositions/1.json
  def update
    respond_to do |format|
      if @composition.update(composition_params)
        format.html { redirect_to [:admin, @composition], notice: 'Composition was successfully updated.' }
        format.json { render :show, status: :ok, location: @composition }
      else
        format.html { render :edit }
        format.json { render json: @composition.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /compositions/1
  # DELETE /compositions/1.json
  def destroy

    @composition.composition_grapes.each do |comp|
      comp.destroy
    end

    @composition.destroy

    respond_to do |format|
      format.html { redirect_to admin_compositions_url, notice: 'Composition was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def import
    results = CompositionImporter.import_compositions(params[:file], %w(composition_id grape1_id))

    if results[:success]
      respond_to do |format|
        format.html { redirect_to admin_compositions_path, notice: 'Compositions were successfully uploaded.' }
      end
    else
      respond_to do |format|
        format.html { redirect_to upload_admin_compositions_path, alert: results[:errors].join(', ') }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_composition
      @composition = Composition.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def composition_params
      params.require(:composition).permit(:name, :subregion_id, :note)
    end
end
