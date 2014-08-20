require 'test_helper'

class WineMaturationsControllerTest < ActionController::TestCase
  setup do
    @wine_maturation = wine_maturations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:wine_maturations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create wine_maturation" do
    assert_difference('WineMaturation.count') do
      post :create, wine_maturation: { maturation_type_id: @wine_maturation.maturation_type_id, period: @wine_maturation.period }
    end

    assert_redirected_to wine_maturation_path(assigns(:wine_maturation))
  end

  test "should show wine_maturation" do
    get :show, id: @wine_maturation
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @wine_maturation
    assert_response :success
  end

  test "should update wine_maturation" do
    patch :update, id: @wine_maturation, wine_maturation: { maturation_type_id: @wine_maturation.maturation_type_id, period: @wine_maturation.period }
    assert_redirected_to wine_maturation_path(assigns(:wine_maturation))
  end

  test "should destroy wine_maturation" do
    assert_difference('WineMaturation.count', -1) do
      delete :destroy, id: @wine_maturation
    end

    assert_redirected_to wine_maturations_path
  end
end
