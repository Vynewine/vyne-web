require 'test_helper'

class MaturationTypesControllerTest < ActionController::TestCase
  setup do
    @maturation_type = maturation_types(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:maturation_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create maturation_type" do
    assert_difference('MaturationType.count') do
      post :create, maturation_type: { name: @maturation_type.name }
    end

    assert_redirected_to maturation_type_path(assigns(:maturation_type))
  end

  test "should show maturation_type" do
    get :show, id: @maturation_type
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @maturation_type
    assert_response :success
  end

  test "should update maturation_type" do
    patch :update, id: @maturation_type, maturation_type: { name: @maturation_type.name }
    assert_redirected_to maturation_type_path(assigns(:maturation_type))
  end

  test "should destroy maturation_type" do
    assert_difference('MaturationType.count', -1) do
      delete :destroy, id: @maturation_type
    end

    assert_redirected_to maturation_types_path
  end
end
