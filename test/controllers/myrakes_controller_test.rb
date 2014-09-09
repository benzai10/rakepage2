require 'test_helper'

class MyrakesControllerTest < ActionController::TestCase

  test 'get redirected for non-signed-in user' do
    get :index

    assert_redirected_to master_rakes_path
  end

end