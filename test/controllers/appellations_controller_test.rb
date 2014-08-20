require 'test_helper'

class AppellationsControllerTest < ActionController::TestCase
  setup do
    @appellation = appellations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:appellations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create appellation" do
    assert_difference('Appellation.count') do
      post :create, appellation: { name: @appellation.name }
    end

    assert_redirected_to appellation_path(assigns(:appellation))
  end

  test "should show appellation" do
    get :show, id: @appellation
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @appellation
    assert_response :success
  end

  test "should update appellation" do
    patch :update, id: @appellation, appellation: { name: @appellation.name }
    assert_redirected_to appellation_path(assigns(:appellation))
  end

  test "should destroy appellation" do
    assert_difference('Appellation.count', -1) do
      delete :destroy, id: @appellation
    end

    assert_redirected_to appellations_path
  end
end
