require 'test_helper'

class GrapesControllerTest < ActionController::TestCase
  setup do
    @grape = grapes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:grapes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create grape" do
    assert_difference('Grape.count') do
      post :create, grape: { grapename_id: @grape.grapename_id, quantity: @grape.quantity }
    end

    assert_redirected_to grape_path(assigns(:grape))
  end

  test "should show grape" do
    get :show, id: @grape
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @grape
    assert_response :success
  end

  test "should update grape" do
    patch :update, id: @grape, grape: { grapename_id: @grape.grapename_id, quantity: @grape.quantity }
    assert_redirected_to grape_path(assigns(:grape))
  end

  test "should destroy grape" do
    assert_difference('Grape.count', -1) do
      delete :destroy, id: @grape
    end

    assert_redirected_to grapes_path
  end
end
