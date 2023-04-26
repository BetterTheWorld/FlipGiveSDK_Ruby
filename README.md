# FlipgiveSDK

## Shop Cloud

Shop Cloud is [FlipGive's](https://app.flipgive.com) drop-in cashback store. If you would like to know more please visit "site" or contact us at "contact".

### Links of Interest

* [FlipGive](https://app.flipgive.com)
* [API Documentation](https://app.flipgive.com)

### Installation

To begin using FlipGiveSDK::ShopCloud, you should have obtained an ID and Secret pair from FlipGive, Store these securely so that they are accesible in your application (Env variables, rails credentials, etc), we'll be using Rails credentials for our examples. If you haven't recieved credentials, please contact us.

Add the gem to yout Gemfile:

```ruby
 $ gem 'flipgive_sdk', git: "https://github.com/BetterTheWorld/FlipGiveSDK_Ruby.git"
```

After you have installed the gem include run the code bellow to initialize the ShopCloud:

```ruby
    FlipgiveSDK::ShopCloud.flip(Rails.application.credentials.shop_cloud_id, Rails.application.credentials.shop_cloud_secret)
``` 
We recomend using it's own initializer file `myapp/config/initializers/shop_cloud.rb`

ShopCloud is now ready to use.

### Usage

TODO: Write usage instructions here

### Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/flipgive_sdk.


## License

Some license