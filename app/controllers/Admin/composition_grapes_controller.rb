class Admin::CompositionGrapesController < ApplicationController
  layout 'admin'
  before_action :authenticate_user!
  authorize_actions_for AdminAuthorizer

  def new
    @composition = Composition.find(params[:composition_id])
    @composition_grape = CompositionGrape.new
    @grapes = Grape.all.order(:name)
  end

  def edit
    @composition_grape = CompositionGrape.find(params[:id])
    @composition = @composition_grape.composition
    @grapes = Grape.all.order(:name)
  end

  def update
    @composition_grape = CompositionGrape.find(params[:id])
    if @composition_grape.update(composition_grape_params)
      redirect_to admin_composition_path(@composition_grape.composition), notice: 'Grape was successfully updated.'
    else
      flash.now[:error] = @composition_grape.errors.full_messages.join(', ')
      @composition = @composition_grape.composition
      render :edit
    end
  end

  def create
    @composition = Composition.find(params[:composition_id])
    @composition_grape = CompositionGrape.new(composition_grape_params)
    @composition_grape.composition = @composition

    if @composition_grape.save
      redirect_to admin_composition_path(@composition_grape.composition), notice: 'Grape was successfully added to composition.'
    else
      flash.now[:error] = @composition_grape.errors.full_messages.join(', ')
      render :new
    end
  end

  def destroy
    @composition_grape = CompositionGrape.find(params[:id])
    @composition_grape.destroy

    redirect_to admin_composition_path(@composition_grape.composition), notice: 'Grape was removed from composition.'
  end

  private

  def composition_grape_params
    params.require(:composition_grape).permit(:grape_id, :percentage)
  end

end