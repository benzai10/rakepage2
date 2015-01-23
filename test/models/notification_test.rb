require "test_helper"

describe Notification do
  let(:notification) { Notification.new }

  it "must be valid" do
    notification.must_be :valid?
  end
end
