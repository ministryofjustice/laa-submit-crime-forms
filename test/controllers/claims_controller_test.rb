require "test_helper"

class ClaimsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get claims_index_url
    assert_response :success
  end

  test "should get show" do
    get claims_show_url
    assert_response :success
  end

  test "should get new" do
    get claims_new_url
    assert_response :success
  end

  test "should get edit" do
    get claims_edit_url
    assert_response :success
  end

  test "should get delete" do
    get claims_delete_url
    assert_response :success
  end
end
