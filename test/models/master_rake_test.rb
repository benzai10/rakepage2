require 'test_helper'

describe MasterRake do

  fixtures :users

  before { user = users(:user) }

  describe "admin user" do
    let(:master_rake_params) { { name: "Master Rake Name", created_by: 1 } }
    let(:master_rake) { MasterRake.new master_rake_params }

    it "is valid with valid params" do
      master_rake.must_be :valid? # Must create with valid params
    end

    it "is invalid without an name" do
      # Delete url before master rake let is called
      master_rake_params.delete :name
      master_rake.wont_be :valid? # Must not be valid without url
      master_rake.errors[:name].must_be :present? # Must have error for missing name
    end
  end

  describe "normal user" do
    let(:master_rake_params) { { name: "Master Rake Name", wikipedia_url: "http://google.com", created_by: 2 } }
    let(:master_rake) { MasterRake.new master_rake_params }

    it "is valid with valid params" do
      master_rake.must_be :valid? # Must create with valid params
    end

    it "is invalid without an name" do
      # Delete url before master rake let is called
      master_rake_params.delete :name
      master_rake.wont_be :valid? # Must not be valid without url
      master_rake.errors[:name].must_be :present? # Must have error for missing name
    end
  end

end