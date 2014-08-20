require 'test_helper'

class WineFoodsControllerTest < ActionController::TestCase
  setup do
    @wine_food = wine_foods(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:wine_foods)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create wine_food" do
    assert_difference('WineFood.count') do
      post :create, wine_food: { name: @wine_food.name }
    end

    assert_redirected_to wine_food_path(assigns(:wine_food))
  end

  test "should show wine_food" do
    get :show, id: @wine_food
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @wine_food
    assert_response :success
  end

  test "should update wine_food" do
    patch :update, id: @wine_food, wine_food: { name: @wine_food.name }
    assert_redirected_to wine_food_path(assigns(:wine_food))
  end

  test "should destroy wine_food" do
    assert_difference('WineFood.count', -1) do
      delete :destroy, id: @wine_food
    end

    assert_redirected_to wine_foods_path
  end
end
