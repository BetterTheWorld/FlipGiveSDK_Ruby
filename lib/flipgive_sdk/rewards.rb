require "jwe"

# class to handle shop cloud tokens
class FlipgiveSDK::Rewards
  COUNTRIES = %w[CAN USA].freeze
  PARTNER_TOKEN_TTL = 3600 # SECONDS

  class << self
    def flip(id, secret)
      @instance = new(id, secret)
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

  def initialize(id, secret)
    @id = id
    @secret = secret.gsub("sk_", nil.to_s)
    @errors = []
  end

  def read_token(token)
    encrypted_string, shop_id = token.split("@")
    raise invalid_token_error if shop_id != id

    json = JWE.decrypt(encrypted_string, secret)
    JSON.parse(json)
  end

  def identified_token(payload)
    raise validation_error unless valid_identified?(payload)

    token = JWE.encrypt(payload.to_json, secret, alg: "dir")
    [token, id].join("@")
  end

  def valid_identified?(payload)
    @errors = []
    @payload = payload
    validate_payload
    validate_person_data(:user, @payload[:user_data]) if @payload[:user_data]
    validate_campaign_data if @payload[:campaign_data]
    validate_group_data if @payload[:group_data]
    validate_organization_data if @payload[:organization_data]
    validate_division_data if @payload[:division_data]
    return true if errors.empty?

    @payload = {}
    false
  end

  def partner_token
    payload = { type: "partner", expires:  partner_token_expiration }
    token = JWE.encrypt(payload.to_json, secret, alg: "dir")
    [token, id].join("@")
  end

  attr_reader :errors

  private

  attr_reader :secret, :id

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

  def validate_person_data(sym, data)
    data = symbolize_keys(data || {})
    sym = "#{sym}_data".to_sym
    validate_presence(sym, data, :id)
    validate_presence(sym, data, :name)
    validate_presence(sym, data, :email)
    validate_inclusion(sym, COUNTRIES, data, :country)
  end

  def validate_campaign_data
    data = symbolize_keys(@payload[:campaign_data] || {})
    validate_presence(:campaign_data, data, :id)
    validate_presence(:campaign_data, data, :name)
    validate_presence(:campaign_data, data, :category)
    validate_inclusion(:campaign_data, COUNTRIES, data, :country)
    validate_person_data(:campaign_admin, data[:admin_data])
  end

  def validate_group_data
    data = symbolize_keys(@payload[:group_data] || {})
    @errors << { group_data: "name missing." } if data[:name].nil?
  end

  def validate_organization_data
    data = symbolize_keys(@payload[:organization_data] || {})
    validate_presence(:organization_data, data, :id)
    validate_presence(:organization_data, data, :name)
    validate_person_data(:organization_admin, data[:admin_data])
  end

  def validate_presence(data_key, data, key)
    @errors << { data_key => "#{key} missing." } if data[key].nil?
  end

  def validate_inclusion(data_key, group, data, key)
    return nil if group.include?(data[key])

    @errors << { data_key => "#{key} must be one of: '#{group.join(", ")}'." }
  end

  def symbolize_keys(hazh)
    return hazh if hazh.empty?

    hazh.transform_keys(&:to_sym)
  end

  def partner_token_expiration
    (Time.now.to_i + PARTNER_TOKEN_TTL)
  end
end
