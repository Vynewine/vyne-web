require 'test_helper'

class GrapenamesControllerTest < ActionController::TestCase
  setup do
    @grapename = grapenames(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:grapenames)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create grapename" do
    assert_difference('Grapename.count') do
      post :create, grapename: { name: @grapename.name }
    end

    assert_redirected_to grapename_path(assigns(:grapename))
  end

  test "should show grapename" do
    get :show, id: @grapename
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @grapename
    assert_response :success
  end

  test "should update grapename" do
    patch :update, id: @grapename, grapename: { name: @grapename.name }
    assert_redirected_to grapename_path(assigns(:grapename))
  end

  test "should destroy grapename" do
    assert_difference('Grapename.count', -1) do
      delete :destroy, id: @grapename
    end

    assert_redirected_to grapenames_path
  end
end
