require "jwt"

# class to handle shop cloud tokens
class FlipgiveSDK::ShopCloud
  TTL = 31536000 # 1.year
  CURRENCIES = %w[CAD USD].freeze

  class << self
    def flip(cloud_shop_id, secret, ttl = nil)
      @cloud_shop_id = cloud_shop_id
      @secret = secret
      @ttl = ttl || TTL
      @errors = []
      :initialized
    end

    def identified_token(payload)
      raise validation_error unless valid_identified?(payload)

      token = JWT.encode({ payload: payload, exp: exp }, secret, "HS256")
      [token, cloud_shop_id].join("@")
    end

    def read_token(token)
      data = token.split("@")
      return nil if data.last != cloud_shop_id

      JWT.decode(data[0], secret, true, { algorithm: "HS256" })
    end

    attr_reader :errors

    def valid_identified?(payload)
      @errors = []
      @payload = payload
      validate_payload
      validate_user_data(:user, @payload[:user_data]) if @payload[:user_data]
      validate_campaign_data if @payload[:campaign_data]
      return true if errors.empty?

      @payload = nil
      false
    end

    private

    def validation_error
      FlipgiveSDK::Error.new("Invalid payload.")
    end

    def validate_payload
      validate_format
      @errors << { payload: "User data missing." } if (@payload.fetch(:user_data, {}) || {}).empty?
    end

    def validate_format
      return @payload = symbolize_keys(@payload) if @payload.is_a?(Hash)

      @payload = {}
      @errors << { payload: "Payload is not a hash." }
    end

    def validate_formatvalidate_format
      return @payload = symbolize_keys(@payload) if @payload.is_a?(Hash)

      @payload = {}
      @errors << { payload: "Payload is not a hash." }
    end

    def validate_user_data(key, data)
      data = symbolize_keys(@payload[:user_data] || {})
      @errors << { "#{key.to_s}_data".to_sym => "#{key.to_s.capitalize} ID missing." } if data[:id].nil?
      @errors << { "#{key.to_s}_data".to_sym => "#{key.to_s.capitalize} name missing." } if data[:name].nil?
      @errors << { "#{key.to_s}_data".to_sym => "#{key.to_s.capitalize} email missing." } if data[:email].nil?

      return if  CURRENCIES.include?(data[:currency])

      @errors << { "#{key.to_s}_data".to_sym => "User currency must be one of: '#{CURRENCIES.join(", ")}'." }
    end

    def validate_campaign_data
      data = symbolize_keys(@payload[:campaign_data] || {})
      @errors << { campaign_data: "Campaign ID missing." } if data[:id].nil?
      @errors << { campaign_data: "Campaign name missing." } if data[:name].nil?
      @errors << { campaign_data: "Campaign category missing." } if data[:category].nil?
      @errors << { campaign_data: "Campaign currency must be one of: '#{CURRENCIES.join(", ")}'." } unless CURRENCIES.include?(data[:currency])
      validate_user_data(:campaign_owner, @payload[:campaign_data][:owner_data])

    end

    def symbolize_keys(hazh)
      return hazh if hazh.empty?

      hazh.transform_keys(&:to_sym)
    end

    def exp
      (Time.now + @ttl).to_i
    end

    attr_reader :secret, :cloud_shop_id
  end
end
