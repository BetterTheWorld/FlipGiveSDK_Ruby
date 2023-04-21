require "jwe"

# class to handle shop cloud tokens
class FlipgiveSDK::ShopCloud
  CURRENCIES = %w[CAD USD].freeze
  PARTNER_TOKEN_TTL = 3600 # SECONDS

  class << self
    def flip(cloud_shop_id, secret)
      @instance = new(cloud_shop_id, secret)
      :initialized
    end

    def read_token(token)
      @instance.read_token(token)
    end

    def identified_token(payload)
      @instance.identified_token(payload)
    end

    def valid_identified?(payload)
      @instance.valid_identified?(payload)
    end

    def partner_token
      @instance.partner_token
    end

    def errors
      @instance.errors
    end
  end

  def initialize(cloud_shop_id, secret)
    @cloud_shop_id = cloud_shop_id
    @secret = secret.gsub("sk_", nil.to_s)
    @errors = []
  end

  def read_token(token)
    encrypted_string, shop_id = token.split("@")
    raise invalid_token_error if shop_id != cloud_shop_id

    json = JWE.decrypt(encrypted_string, secret)
    JSON.parse(json)
  end

  def identified_token(payload)
    raise validation_error unless valid_identified?(payload)

    token = JWE.encrypt(payload.to_json, secret, alg: "dir")
    [token, cloud_shop_id].join("@")
  end

  def valid_identified?(payload)
    @errors = []
    @payload = payload
    validate_payload
    validate_person_data(:user, @payload[:user_data]) if @payload[:user_data]
    validate_campaign_data if @payload[:campaign_data]
    validate_team_data if @payload[:team_data]
    return true if errors.empty?

    @payload = {}
    false
  end

  def partner_token
    payload = { type: "partner_token", expires:  partner_token_ttl }
    token = JWE.encrypt(payload.to_json, secret, alg: "dir")
    [token, cloud_shop_id].join("@")
  end

  attr_reader :errors

  private

  attr_reader :secret, :cloud_shop_id

  def invalid_token_error
    FlipgiveSDK::Error.new("Invalid Token.")
  end

  def validation_error
    FlipgiveSDK::Error.new("Invalid payload.")
  end

  def validate_payload
    validate_format
    validate_minimun_data
  end

  def validate_format
    if @payload.is_a?(Hash)
      @payload = symbolize_keys(@payload)
    else
      @errors << { payload: "Payload must be a Hash." }
      @payload = {}
    end
  end

  def validate_minimun_data
    return nil if (@payload[:user_data] || @payload[:campaign_data] || {}).any?

    @errors << { payload: "At least must contain user_data or campaign_data." }
  end

  def validate_person_data(key, data)
    data = symbolize_keys(data || {})
    sym = "#{key}_data".to_sym 
    string = key.to_s.capitalize
    @errors << { sym => "#{string} ID missing." } if data[:id].nil?
    @errors << { sym => "#{string} name missing." } if data[:name].nil?
    @errors << { sym => "#{string} email missing." } if data[:email].nil?

    return if  CURRENCIES.include?(data[:currency])

    @errors << { sym => "Currency must be one of: '#{CURRENCIES.join(", ")}'." }
  end

  def validate_campaign_data
    data = symbolize_keys(@payload[:campaign_data] || {})
    @errors << { campaign_data: "Campaign ID missing." } if data[:id].nil?
    @errors << { campaign_data: "Campaign name missing." } if data[:name].nil?
    @errors << { campaign_data: "Campaign category missing." } if data[:category].nil?
    unless CURRENCIES.include?(data[:currency])
      @errors << { campaign_data: "Campaign currency must be one of: '#{CURRENCIES.join(", ")}'." }
    end
    validate_person_data(:campaign_owner, data[:owner_data])
  end

  def validate_group_data
    data = symbolize_keys(@payload[:group_data] || {})
    @errors << { campaign_data: "Team name missing." } if data[:name].nil?
  end

  def symbolize_keys(hazh)
    return hazh if hazh.empty?

    hazh.transform_keys(&:to_sym)
  end

  def partner_token_ttl
    (Time.now.to_i + PARTNER_TOKEN_TTL)
  end
end
