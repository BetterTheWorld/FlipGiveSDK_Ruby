# frozen_string_literal: true
require 'securerandom'

RSpec.describe FlipgiveSDK::ShopCloud do

  before(:all) do
    FlipgiveSDK::ShopCloud.flip("pidba98131be", "verysecrettoken57e6323c7c74bba0e9fd4d702aeea756c0901e3a6b453671a")
  end

  let(:secret) { "verysecrettoken57e6323c7c74bba0e9fd4d702aeea756c0901e3a6b453671a" }
  let(:partner_id) { "pidba98131be" }

  let(:user_data) {{
    "id" => 3141592,
    "name" => 'Emmet Brown',
    "email" => 'ebrown@time.com',
    "currency"=> 'CAD',
    "is_captain" => false
  }}
  let(:campaign_data) {{
    "id" => 3141592,
    "name" => 'The Time Travelers',
    "category" => 'Running',
    "currency"=> 'CAD'
  }}


  let(:payload) {{
    "user_data" => user_data,
    "campaign_data" => campaign_data
  }}

  it "expects ShopCloud to exist" do
    expect(FlipgiveSDK::ShopCloud).not_to be nil
  end

  it "expects secret and partner id" do

    expect(FlipgiveSDK::ShopCloud).to receive(:secret).and_return(secret)
    expect(FlipgiveSDK::ShopCloud).to receive(:partner_id).and_return(partner_id)
    allow(FlipgiveSDK::ShopCloud).to receive(:valid_identified?).and_return true

    FlipgiveSDK::ShopCloud.identified_token({foo: 'bar'})
  end

  it "expects token to be generated and append partner_id" do

    token = FlipgiveSDK::ShopCloud.identified_token(payload)
    regexp = Regexp.new("#{partner_id}\\z")

    expect(token).to be_kind_of(String)
    expect(token).to match(regexp)
  end

  it "expects invalid params error" do

    payload = 'foobar'

    expect{FlipgiveSDK::ShopCloud.identified_token(payload)}.to raise_error(FlipgiveSDK::Error)
  end

  it "expects invalid user_data_errors" do
    payload["user_data"] = nil
    expect{FlipgiveSDK::ShopCloud.identified_token(payload)}.to raise_error(FlipgiveSDK::Error)
    expect(FlipgiveSDK::ShopCloud.errors).not_to be_empty
    # HERE
    pp FlipgiveSDK::ShopCloud.errors
  end

  it "expects token to be successfully decoded" do

    expected = {"foo" => 'bar'}

    token = FlipgiveSDK::ShopCloud.identified_token(payload)
    data = FlipgiveSDK::ShopCloud.read_token(token)
    
    expect(data[0]['payload']).to eq(payload) 
  end

  it "expects token to have expired" do
    FlipgiveSDK::ShopCloud.flip(partner_id, secret, -10)

    token = FlipgiveSDK::ShopCloud.identified_token(payload)
    
    expect{FlipgiveSDK::ShopCloud.read_token(token)}.to raise_error(JWT::ExpiredSignature)
  end


end
