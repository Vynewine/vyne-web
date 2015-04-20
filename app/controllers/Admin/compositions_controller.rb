class Admin::CompositionsController < ApplicationController

  layout 'admin'
  before_action :authenticate_user!
  authorize_actions_for AdminAuthorizer
  before_action :set_composition, only: [:show, :edit, :update, :destroy]

  def index
    @compositions = Composition.order(:id).page(params[:page])
  end

  def show
  end

  def new
    @composition = Composition.new
  end

  def edit
  end

  def create
    @composition = Composition.new(composition_params)

    if @composition.save
      redirect_to admin_composition_path(@composition), notice: 'Composition was successfully created.'
    else
      flash.now[:error] = @composition.errors.full_messages.join(', ')
      render :new
    end
  end

  def update
    if @composition.update(composition_params)
      redirect_to admin_composition_path(@composition), notice: 'Composition was successfully updated.'
    else
      flash.now[:error] = @composition.errors.full_messages.join(', ')
      render :edit
    end
  end

  def destroy

    @composition.composition_grapes.each do |comp|
      comp.destroy
    end

    @composition.destroy

    redirect_to admin_compositions_url, notice: 'Composition was successfully destroyed.'
  end

  def import
    results = CompositionImporter.import_compositions(params[:file], %w(composition_id grape1_id))

    if results[:success]
        redirect_to admin_compositions_path, notice: 'Compositions were successfully uploaded.'
    else
      redirect_to upload_admin_compositions_path, alert: results[:errors].join(', ')
    end
  end

  private
  def set_composition
    @composition = Composition.find(params[:id])
  end

  def composition_params
    params.require(:composition).permit(:name, :note)
  end
end
