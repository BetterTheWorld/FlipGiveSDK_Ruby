# frozen_string_literal: true

require "securerandom"

RSpec.describe FlipgiveSDK::ShopCloud do
  before(:all) do
    FlipgiveSDK::ShopCloud.flip("BB126923", "verysecrettoken57e6323c7c74bba0e9fd4d702aeea756c0901e3a6b453671a")
  end

  let(:secret) { "verysecrettoken57e6323c7c74bba0e9fd4d702aeea756c0901e3a6b453671a" }
  let(:cloud_shop_id) { "BB126923" }

  let(:user_data) do
    {
      "id" => 3_141_592,
      "name" => "Emmet Brown",
      "email" => "ebrown@time.com",
      "currency" => "CAD"
    }
  end

  let(:campaign_data) do
    {
      "id" => 3_141_592,
      "name" => "The Time Travelers",
      "category" => "Running",
      "currency" => "CAD",
      "owner_data" => user_data 
    }
  end

  let(:payload) do
    {
      "user_data" => user_data,
      "campaign_data" => campaign_data
    }
  end

  it "expects ShopCloud to exist" do
    expect(FlipgiveSDK::ShopCloud).not_to be nil
  end

  it "expects secret and partner id" do
    expect(FlipgiveSDK::ShopCloud).to receive(:secret).and_return(secret)
    expect(FlipgiveSDK::ShopCloud).to receive(:cloud_shop_id).and_return(cloud_shop_id)
    allow(FlipgiveSDK::ShopCloud).to receive(:valid_identified?).and_return true

    FlipgiveSDK::ShopCloud.identified_token({ foo: "bar" })
  end

  it "expects token to be generated and append cloud_shop_id" do
    token = FlipgiveSDK::ShopCloud.identified_token(payload)
    regexp = Regexp.new("#{cloud_shop_id}\\z")

    expect(token).to be_kind_of(String)
    expect(token).to match(regexp)
  end

  it "expects invalid params error" do
    payload = "foobar"

    expect { FlipgiveSDK::ShopCloud.identified_token(payload) }.to raise_error(FlipgiveSDK::Error)
  end

  it "expects invalid user_data_errors" do
    payload["user_data"] = {}
    payload["campaign_data"] = nil

    expect { FlipgiveSDK::ShopCloud.identified_token(payload) }.to raise_error(FlipgiveSDK::Error)
    expect(FlipgiveSDK::ShopCloud.errors).not_to be_empty
    expect(FlipgiveSDK::ShopCloud.errors.count).to eq(5)
    expect(FlipgiveSDK::ShopCloud.errors[0][:payload]).to eq("At least must contain user_data or campaign_data.")
    expect(FlipgiveSDK::ShopCloud.errors[1][:user_data]).to eq("User ID missing.")
    expect(FlipgiveSDK::ShopCloud.errors[2][:user_data]).to eq("User name missing.")
    expect(FlipgiveSDK::ShopCloud.errors[3][:user_data]).to eq("User email missing.")
    expect(FlipgiveSDK::ShopCloud.errors[4][:user_data]).to eq("Currency must be one of: 'CAD, USD'.")
  end

  it "expects invalid campaign_data" do
    payload["user_data"] = nil
    payload["campaign_data"] = {}

    expect { FlipgiveSDK::ShopCloud.identified_token(payload) }.to raise_error(FlipgiveSDK::Error)
    expect(FlipgiveSDK::ShopCloud.errors).not_to be_empty
    expect(FlipgiveSDK::ShopCloud.errors.count).to eq(9)
    expect(FlipgiveSDK::ShopCloud.errors[0][:payload]).to eq("At least must contain user_data or campaign_data.")
    expect(FlipgiveSDK::ShopCloud.errors[1][:campaign_data]).to eq("Campaign ID missing.")
    expect(FlipgiveSDK::ShopCloud.errors[2][:campaign_data]).to eq("Campaign name missing.")
    expect(FlipgiveSDK::ShopCloud.errors[3][:campaign_data]).to eq("Campaign category missing.")
    expect(FlipgiveSDK::ShopCloud.errors[4][:campaign_data]).to eq("Campaign currency must be one of: 'CAD, USD'.")
    expect(FlipgiveSDK::ShopCloud.errors[5][:campaign_owner_data]).to eq("Campaign_owner ID missing.")
    expect(FlipgiveSDK::ShopCloud.errors[6][:campaign_owner_data]).to eq("Campaign_owner name missing.")
    expect(FlipgiveSDK::ShopCloud.errors[7][:campaign_owner_data]).to eq("Campaign_owner email missing.")
    expect(FlipgiveSDK::ShopCloud.errors[8][:campaign_owner_data]).to eq("Currency must be one of: 'CAD, USD'.")
  end

  it "expects token to be successfully decoded" do
    token = FlipgiveSDK::ShopCloud.identified_token(payload)
    data = FlipgiveSDK::ShopCloud.read_token(token)

    expect(data[0]["payload"]).to eq(payload)
  end

  it "expects token to have expired" do
    FlipgiveSDK::ShopCloud.flip(cloud_shop_id, secret, -10)

    token = FlipgiveSDK::ShopCloud.identified_token(payload)

    expect { FlipgiveSDK::ShopCloud.read_token(token) }.to raise_error(JWT::ExpiredSignature)
  end
end
