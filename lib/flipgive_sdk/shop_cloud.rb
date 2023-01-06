require 'jwt'

class FlipgiveSDK::ShopCloud
  TTL = 3600.freeze
  CURRENCIES = %w(CAD USD).freeze

  class << self
    def flip(cloud_shop_id, secret, ttl=nil)
      @cloud_shop_id = cloud_shop_id
      @secret = secret
      @ttl = ttl || TTL
      @errors = []
      :initialized
    end

    def identified_token(payload)
      raise validation_error unless valid_identified?(payload)
      token = JWT.encode({payload: payload, exp: exp}, secret, 'HS256')
      [token, cloud_shop_id].join('@')
    end

    def anonymous_token(payload)
      raise validation_error unless valid_anonymous?(payload)
      token = JWT.encode({payload: payload, exp: exp}, secret, 'HS256')
      [token, cloud_shop_id].join('@')
    end

    def read_token(token)
      data = token.split('@')
      return nil if data.last != cloud_shop_id
      JWT.decode(data[0], secret, true, { algorithm: 'HS256' })
    end

    def errors
      @errors
    end

    def valid_identified?(payload)
      @errors = []
      @payload = payload
      validate_payload
      validate_user_data
      validate_campaign_data
      return true if errors.empty?
      @payload = nil
      false
    end

    def valid_anonymous?(payload)
      @errors = []
      @payload = payload
      validate_payload
      validate_minimun_data
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
      @errors << {payload: "User data missing."} if (@payload.fetch(:user_data, {}) || {}).empty?
      @errors << {payload: "Campaign data missing."} if (@payload.fetch(:campaign_data, {}) || {}).empty?
    end

    def validate_format
      return @payload = symbolize_keys(@payload) if @payload.kind_of?(Hash)
      @payload = {}
      @errors << {payload: 'Payload is not a hash.'}
    end

    def validate_user_data
      data = symbolize_keys(@payload[:user_data] || {})
      @errors << {user_data: "User ID missing."} if data[:id].nil?
      @errors << {user_data: "User name missing."} if data[:name].nil?
      @errors << {user_data: "User email missing."} if data[:email].nil?
      @errors << {user_data: "User currency must be one of: '#{CURRENCIES.join(', ')}'."} unless CURRENCIES.include?(data[:currency])
    end

    def validate_campaign_data
      data = symbolize_keys(@payload[:campaign_data] || {})
      @errors << {campaign_data: "Campaign ID missing."} if data[:id].nil?
      @errors << {campaign_data: "Campaign name missing."} if data[:name].nil?
      @errors << {campaign_data: "Campaign category missing."} if data[:category].nil?
      @errors << {campaign_data: "Campaign currency must be one of: '#{CURRENCIES.join(', ')}'."} unless CURRENCIES.include?(data[:currency])
    end

    def symbolize_keys(hazh)
      return hazh if hazh.empty?
      Hash[hazh.map{ |key, value| [key.to_sym, value] }]
    end

    def exp
      (Time.now + @ttl).to_i
    end

    def secret
      @secret
    end

    def cloud_shop_id
      @cloud_shop_id
    end
  end
end
