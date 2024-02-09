# frozen_string_literal: true

require "securerandom"
# verysecrettoken57e6323c7c74bba0e9fd4d702aeea756c0901e3a6b453671a

RSpec.describe FlipgiveSDK::Rewards do
  before(:all) do
    FlipgiveSDK::Rewards.flip("BB126923", "sk_61c394cf3346077b")
  end

  let(:secret) { "61c394cf3346077b" }
  let(:id) { "BB126923" }

  let(:user_data) { RewardsHelper.person_data }
  let(:campaign_data) { RewardsHelper.campaign_data }
  let(:group_data) { RewardsHelper.group_data }
  let(:organization_data) { RewardsHelper.organization_data }

  let(:payload) do
    {
      "user_data" => user_data,
      "campaign_data" => campaign_data
    }
  end

  context "#Rewards" do
    it "expects Rewards to exist" do
      expect(FlipgiveSDK::Rewards).not_to be nil
    end
  end
  context "#initialize" do
    it "expects secret and partner id" do
      fg_shop_cloud = FlipgiveSDK::Rewards.new("BB126923", "sk_61c394cf3346077b")
      expect(fg_shop_cloud).to receive(:secret).and_return(secret)
      expect(fg_shop_cloud).to receive(:id).and_return(id)
      allow(fg_shop_cloud).to receive(:valid_identified?).and_return true

      fg_shop_cloud.identified_token({ foo: "bar" })
    end
  end

  context "#token" do
    it "expects token to be generated and append id" do
      token = FlipgiveSDK::Rewards.identified_token(payload)
      regexp = Regexp.new("#{id}\\z")

      expect(token).to be_kind_of(String)
      expect(token).to match(regexp)
    end

    it "expects invalid params error" do
      payload = "foobar"

      expect { FlipgiveSDK::Rewards.identified_token(payload) }.to raise_error(FlipgiveSDK::Error)
    end

    it "expects invalid user_data_errors" do
      payload["user_data"] = {}
      payload["campaign_data"] = nil

      expect { FlipgiveSDK::Rewards.identified_token(payload) }.to raise_error(FlipgiveSDK::Error)
      expect(FlipgiveSDK::Rewards.errors).not_to be_empty
      expect(FlipgiveSDK::Rewards.errors.count).to eq(5)
      expect(FlipgiveSDK::Rewards.errors[0][:payload]).to eq("At least must contain user_data or campaign_data.")
      expect(FlipgiveSDK::Rewards.errors[1][:user_data]).to eq("id missing.")
      expect(FlipgiveSDK::Rewards.errors[2][:user_data]).to eq("name missing.")
      expect(FlipgiveSDK::Rewards.errors[3][:user_data]).to eq("email missing.")
      expect(FlipgiveSDK::Rewards.errors[4][:user_data]).to eq("country must be one of: 'CAN, USA'.")
    end

    it "expects invalid campaign_data" do
      payload["user_data"] = nil
      payload["campaign_data"] = {}

      expect { FlipgiveSDK::Rewards.identified_token(payload) }.to raise_error(FlipgiveSDK::Error)
      expect(FlipgiveSDK::Rewards.errors).not_to be_empty
      expect(FlipgiveSDK::Rewards.errors.count).to eq(9)
      expect(FlipgiveSDK::Rewards.errors[0][:payload]).to eq("At least must contain user_data or campaign_data.")
      expect(FlipgiveSDK::Rewards.errors[1][:campaign_data]).to eq("id missing.")
      expect(FlipgiveSDK::Rewards.errors[2][:campaign_data]).to eq("name missing.")
      expect(FlipgiveSDK::Rewards.errors[3][:campaign_data]).to eq("category missing.")
      expect(FlipgiveSDK::Rewards.errors[4][:campaign_data]).to eq("country must be one of: 'CAN, USA'.")
      expect(FlipgiveSDK::Rewards.errors[5][:campaign_admin_data]).to eq("id missing.")
      expect(FlipgiveSDK::Rewards.errors[6][:campaign_admin_data]).to eq("name missing.")
      expect(FlipgiveSDK::Rewards.errors[7][:campaign_admin_data]).to eq("email missing.")
      expect(FlipgiveSDK::Rewards.errors[8][:campaign_admin_data]).to eq("country must be one of: 'CAN, USA'.")
    end

    it "expects token to be successfully decoded" do
      token = FlipgiveSDK::Rewards.identified_token(payload)
      data = FlipgiveSDK::Rewards.read_token(token)
      expect(data).to eq(payload)
    end

    it "Partner token has partner_token type" do
      token = FlipgiveSDK::Rewards.partner_token
      data = FlipgiveSDK::Rewards.read_token(token)
      expect(data["type"]).to eq("partner")
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
      token = FlipgiveSDK::Rewards.identified_token(payload)
      data = FlipgiveSDK::Rewards.read_token(token)
      expect(data).to eq(payload)
    end
    it "expects error when group_data missing" do
      payload["group_data"] = {}
      expect { FlipgiveSDK::Rewards.identified_token(payload) }.to raise_error(FlipgiveSDK::Error)
      expect(FlipgiveSDK::Rewards.errors).not_to be_empty
      expect(FlipgiveSDK::Rewards.errors.count).to eq(1)
      expect(FlipgiveSDK::Rewards.errors[0][:group_data]).to eq("name missing.")
    end
  end

  context "Organization Data" do
    let(:payload) do
      {
        "user_data" => user_data,
        "campaign_data" => campaign_data,
        "organization_data" => organization_data
      }
    end
    it "expects token to be successfully decoded" do
      token = FlipgiveSDK::Rewards.identified_token(payload)
      data = FlipgiveSDK::Rewards.read_token(token)
      expect(data).to eq(payload)
    end
    it "expects error when organization_data missing" do
      payload["organization_data"] = {}
      expect { FlipgiveSDK::Rewards.identified_token(payload) }.to raise_error(FlipgiveSDK::Error)
      expect(FlipgiveSDK::Rewards.errors).not_to be_empty
      expect(FlipgiveSDK::Rewards.errors.count).to eq(6)
      expect(FlipgiveSDK::Rewards.errors[0][:organization_data]).to eq("id missing.")
      expect(FlipgiveSDK::Rewards.errors[1][:organization_data]).to eq("name missing.")
    end
  end
end
