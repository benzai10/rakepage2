require 'test_helper'

class MasterRakesControllerTest < ActionController::TestCase
  test 'get index' do
    get :index

    assert_response :success
    assert_template :index
    assert_not_nil assigns(:master_rakes)
  end
end