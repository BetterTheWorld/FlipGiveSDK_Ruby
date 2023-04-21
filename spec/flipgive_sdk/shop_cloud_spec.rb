# frozen_string_literal: true

require "securerandom"
# verysecrettoken57e6323c7c74bba0e9fd4d702aeea756c0901e3a6b453671a

RSpec.describe FlipgiveSDK::ShopCloud do
  before(:all) do
    FlipgiveSDK::ShopCloud.flip("BB126923", "sk_61c394cf3346077b")
  end

  let(:secret) { "61c394cf3346077b" }
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

  let(:group_data) do
    {
      "name" => "Player 1"
    }
  end

  let(:payload) do
    {
      "user_data" => user_data,
      "campaign_data" => campaign_data
    }
  end

  context "#ShopCloud" do
    it "expects ShopCloud to exist" do
      expect(FlipgiveSDK::ShopCloud).not_to be nil
    end
  end
  context "#initialize" do
    it "expects secret and partner id" do
      fg_shop_cloud = FlipgiveSDK::ShopCloud.new("BB126923", "sk_61c394cf3346077b")
      expect(fg_shop_cloud).to receive(:secret).and_return(secret)
      expect(fg_shop_cloud).to receive(:cloud_shop_id).and_return(cloud_shop_id)
      allow(fg_shop_cloud).to receive(:valid_identified?).and_return true

      fg_shop_cloud.identified_token({ foo: "bar" })
    end
  end

  context "#token" do
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
      expect(data).to eq(payload)
    end

    it "Partner token has partner_token type" do
      token = FlipgiveSDK::ShopCloud.partner_token
      data = FlipgiveSDK::ShopCloud.read_token(token)
      expect(data["type"]).to eq("partner_token")
      expect(data["expires"]).to eq(Time.now.to_i + 3600)
    end
  end

  context "Group Data" do
    let(:payload) do
      {
        "user_data" => user_data,
        "campaign_data" => campaign_data,
        "group_data" => group_data
      }
    end
    it "expects token to be successfully decoded" do
      token = FlipgiveSDK::ShopCloud.identified_token(payload)
      data = FlipgiveSDK::ShopCloud.read_token(token)
      expect(data).to eq(payload)
    end
  end
end
