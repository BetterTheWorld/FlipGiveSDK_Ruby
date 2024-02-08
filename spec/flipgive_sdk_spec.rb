# frozen_string_literal: true

RSpec.describe FlipgiveSDK do
  it "has a version number" do
    expect(FlipgiveSDK::VERSION).not_to be nil
  end

  it "expects Rewards to exist" do
    expect(FlipgiveSDK::Rewards).not_to be nil
  end
end
