require 'test_helper'

class WineNotesControllerTest < ActionController::TestCase
  setup do
    @wine_note = wine_notes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:wine_notes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create wine_note" do
    assert_difference('WineNote.count') do
      post :create, wine_note: { name: @wine_note.name }
    end

    assert_redirected_to wine_note_path(assigns(:wine_note))
  end

  test "should show wine_note" do
    get :show, id: @wine_note
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @wine_note
    assert_response :success
  end

  test "should update wine_note" do
    patch :update, id: @wine_note, wine_note: { name: @wine_note.name }
    assert_redirected_to wine_note_path(assigns(:wine_note))
  end

  test "should destroy wine_note" do
    assert_difference('WineNote.count', -1) do
      delete :destroy, id: @wine_note
    end

    assert_redirected_to wine_notes_path
  end
end
