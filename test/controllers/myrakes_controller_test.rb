require 'test_helper'

class MyrakesControllerTest < ActionController::TestCase

  test 'get redirected for non-signed-in user' do
    get :index

    assert_redirected_to master_rakes_path
  end

  test 'get redirected if no personal rakes' do
    sign_in Fabricate(:user, id: 2)
    get :index

    assert_redirected_to master_rakes_path
  end

  test 'get index for signed-in user and rakes exist' do
    sign_in Fabricate(:user, id: 100)
    Fabricate(:myrake, user_id: 100)

    get :index
    assert_response :success
  end

end