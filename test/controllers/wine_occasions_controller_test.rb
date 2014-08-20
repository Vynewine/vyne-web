require 'test_helper'

class WineOccasionsControllerTest < ActionController::TestCase
  setup do
    @wine_occasion = wine_occasions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:wine_occasions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create wine_occasion" do
    assert_difference('WineOccasion.count') do
      post :create, wine_occasion: { name: @wine_occasion.name }
    end

    assert_redirected_to wine_occasion_path(assigns(:wine_occasion))
  end

  test "should show wine_occasion" do
    get :show, id: @wine_occasion
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @wine_occasion
    assert_response :success
  end

  test "should update wine_occasion" do
    patch :update, id: @wine_occasion, wine_occasion: { name: @wine_occasion.name }
    assert_redirected_to wine_occasion_path(assigns(:wine_occasion))
  end

  test "should destroy wine_occasion" do
    assert_difference('WineOccasion.count', -1) do
      delete :destroy, id: @wine_occasion
    end

    assert_redirected_to wine_occasions_path
  end
end
