require 'test_helper'

class WineAllergiesControllerTest < ActionController::TestCase
  setup do
    @wine_allergy = wine_allergies(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:wine_allergies)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create wine_allergy" do
    assert_difference('WineAllergy.count') do
      post :create, wine_allergy: { name: @wine_allergy.name }
    end

    assert_redirected_to wine_allergy_path(assigns(:wine_allergy))
  end

  test "should show wine_allergy" do
    get :show, id: @wine_allergy
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @wine_allergy
    assert_response :success
  end

  test "should update wine_allergy" do
    patch :update, id: @wine_allergy, wine_allergy: { name: @wine_allergy.name }
    assert_redirected_to wine_allergy_path(assigns(:wine_allergy))
  end

  test "should destroy wine_allergy" do
    assert_difference('WineAllergy.count', -1) do
      delete :destroy, id: @wine_allergy
    end

    assert_redirected_to wine_allergies_path
  end
end
