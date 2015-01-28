class Admin::UsersController < ApplicationController
  layout "admin"
  before_action :authenticate_user!
  authorize_actions_for AdminAuthorizer # Triggers superadmin check
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    if params[:s]
      @search = User.search do
        fulltext "#{params[:s]}"
      end
      @users = @search.results
    else
      if params[:show_deleted]
        @users = User.only_deleted.page(params[:page]).order(:id)
      else
        @users = User.all.page(params[:page]).order(:id)
      end
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
    @roles = Role.all
  end

  # GET /users/1/edit
  def edit
    @roles = Role.all
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to [:admin, @user], notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { redirect_to new_admin_user_path, alert: @user.errors.full_messages().join(', ') }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    # @roles = Role.all
    params[:user][:role_ids] ||= []
    puts json: user_params
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to [:admin, @user], notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { redirect_to edit_admin_user_path(@user), alert: @user.errors.full_messages().join(', ') }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy

    if @user.has_role? :superadmin
      respond_to do |format|
        format.html { redirect_to admin_users_url, alert: 'Can\'t destroy superadmin users.' }
        format.json { render json: 'Can\'t destroy superadmin users.', status: :unprocessable_entity }
      end
      return
    end

    @user.email = @user.email + '.' + @user.id.to_s + '.deleted.com'
    unless @user.save
      respond_to do |format|
        format.html { redirect_to admin_users_url, alert: @user.errors.full_messages().join(', ') }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
      return
    end
    @user.destroy
    respond_to do |format|
      format.html { redirect_to admin_users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(
        :first_name,
        :last_name,
        :mobile,
        :email,
        :address_id,
        :active,
        :code,
        :password,
        :stripe_id,
        role_ids: [],
        addresses_attributes: [:id, :line_1, :postcode, :line_2, :company_name]
    )
  end
end
