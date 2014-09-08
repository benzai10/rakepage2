require 'test_helper'

describe MasterRake do

  let(:master_rake_params) { { name: "Master Rake Name" } }
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