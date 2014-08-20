require 'test_helper'

class WineTypesControllerTest < ActionController::TestCase
  setup do
    @wine_type = wine_types(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:wine_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create wine_type" do
    assert_difference('WineType.count') do
      post :create, wine_type: { name: @wine_type.name }
    end

    assert_redirected_to wine_type_path(assigns(:wine_type))
  end

  test "should show wine_type" do
    get :show, id: @wine_type
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @wine_type
    assert_response :success
  end

  test "should update wine_type" do
    patch :update, id: @wine_type, wine_type: { name: @wine_type.name }
    assert_redirected_to wine_type_path(assigns(:wine_type))
  end

  test "should destroy wine_type" do
    assert_difference('WineType.count', -1) do
      delete :destroy, id: @wine_type
    end

    assert_redirected_to wine_types_path
  end
end
