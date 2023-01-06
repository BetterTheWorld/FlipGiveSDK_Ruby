# frozen_string_literal: true

RSpec.describe FlipgiveSDK do
  it "has a version number" do
    expect(FlipgiveSDK::VERSION).not_to be nil
  end

  xit "does something useful" do
    expect(false).to eq(true)
  end

  it "expects ShopCloud to exist" do
    expect(FlipgiveSDK::ShopCloud).not_to be nil
  end
end
