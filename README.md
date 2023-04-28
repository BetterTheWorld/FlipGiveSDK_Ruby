# FlipgiveSDK

## Shop Cloud

Shop Cloud(The Shop) is [FlipGive's](https://app.flipgive.com) drop-in cashback store. If you would like to know more please visit "site" or contact us at "contact".

### Links of Interest

* [FlipGive](https://app.flipgive.com)
* [API Documentation](https://app.flipgive.com)

### Installation

To begin using FlipGiveSDK::ShopCloud, you should have obtained an ID and Secret pair from FlipGive, Store these securely so that they are accessible in your application (Env variables, rails credentials, etc), we'll be using Env variables for our example. If you haven't received credentials, please contact us.

Add the gem to your Gemfile:

```ruby
 $ gem 'flipgive_sdk', git: "https://github.com/BetterTheWorld/FlipGiveSDK_Ruby.git"
```

After you have installed the gem include run the code bellow to initialize the ShopCloud:

```ruby
    $ FlipgiveSDK::ShopCloud.flip(ENV['shop_cloud_id'], ENV['shop_cloud_secret'])
```
We recommend using it's own initializer file `myapp/config/initializers/shop_cloud.rb`

ShopCloud is now ready to use.

### Usage

The main purpose of FlipgiveSDK::ShopCloud is to generate Tokens to pass to the Front End portion of ShopCloud. There are 5 methods on the gem's public API, aside from the `:flip` method used to initialize The Shop.

#### :read_token
This method is used to decode a token that has been generated with your credentials. It takes a single string as a param, and if able to decode the token, it will return a hash.

```ruby
    token = "eyJhbGciOiJkaXIiLCJlbmMiOiJBMTI4R0NNIn0..demoToken.g8PZPWb1KDFcAkTsufZq0w@A2DE537C"
    $ FlipgiveSDK::ShopCloud.read_token(token)
    => { user_data: { id: 1, name: 'Emmett Brown', email: 'ebrown@time.ca', country: 'CAN' } }
```

#### :identified_token
This method is used to generate a token that will identify a user or campaign. It accepts a **Payload Hash** as an argument and it returns an encrypted token. The Payload hash requires the following parameters:

- user_data: Required when campaign_data is not present in the payload, otherwise optional. It represents the user using the Shop, and must contain:
  1. id: A string representing the user's ID in your system.
  2. email: A string  with the user's email.
  3. name: A string  with the user's name.
  4. country: A string  with the ISO code of the user's country, which must be 'CAD' or 'USA' at this time.

  ```ruby
    $ user_data = {
      id: 19850703,
      name: 'Emmett Brown',
      email: 'ebrown@time.ca',
      country: 'CAN'
    }
  ```

- campaign_data: Required when user_data is not present in the payload, otherwise optional. It represents the fundraising campaign and it must contain:
  1. id: A string representing the user's ID in your system.
  2. name: A string  with the campaign's email.
  3. category: A string  with the campaign's category. We will try to match it with one of our existing categories, or assign a default. You can see a list of our categories [here](https://github.com/BetterTheWorld/FlipGiveSDK_Ruby/blob/main/categories.txt).
  4. country: A string  with the ISO code of the campaign's country, which must be 'CAD' or 'USA' at this time.
  5. admin_data: The user information for the campaign's admin. It must contain the same information as `user_data`

  ```ruby
    $ campaign_data = {
      id: 19551105,
      name: 'The Time Travelers',
      category: 'Running',
      country: 'CAN',
      admin_data: user_data
    }
  ```

- group_data: Always optional. Groups are aggregators for users within a campaign. For example, a group can be a Player on a sport's team and the users would the be the people supporting them.
  1. name: A string  with the group's name.
  2. player_number: Optional. A sport's player number on the team.

  ```ruby
    $ group_data = { name: 'Marty McFly' }
  ```

- organization_data: Always optional.
  1. id: A string  with the organization's ID.
  2. name: A string  with the organization's name.
  3. organization_admin: The user information for the organization's admin. It must contain the same information as `user_data`

    ```ruby
    $ organization_data = {
      id: 980,
      name: 'Back to the Future',
      admin_data: user_data
    }
  ```

Note: Parameters are mandatory unless specifically marked optional.

```ruby
    $ payload = {
      user_data: user_data,
      campaign_data: campaign_data,
      group_data: group_data,
      organization_data: organization_data
    }
    $ FlipgiveSDK::ShopCloud.identified_token(payload)
    => "eyJhbGciOiJkaXIiLCJlbmMiOiJBMTI4R0NNIn0..demoToken.g8PZPWb1KDFcAkTsufZq0w@A2DE537C"
```

#### :valid_identified?
This method is used to validate a payload, without attempting to generate a token. It returns a Boolean. The same rules for `:identigied_token` apply here as well.

```ruby
    $ payload = { user_data: user_data }  
    $ FlipgiveSDK::ShopCloud.valid_identified?(payload)
    => true
```

#### :partner_token
This method is used to generate a token that can be used ny the Shop Cloud partner (that's you) to access reports and other backoffice endpoints.


```ruby
    $ FlipgiveSDK::ShopCloud.partner_token
    => "eyJhbGciOiJkaXIiLCJlbmMiOiJBMTI4R0NNIn0..demoToken.h9QXQEn2LFGVSlTdiGXW1e@A2DE537C"
```

#### :errors
Validation errors that occur while attempting to generate a token can be retrieved here.

```ruby
    $ user_data[:country] = 'ENG'
    $ payload = { user_data: user_data }
    $ FlipgiveSDK::ShopCloud.valid_identified?(payload)
    # FlipgiveSDK::Error (Invalid payload.)
    $ FlipgiveSDK::ShopCloud.errors
    => [{:user_data=>"Country must be one of: 'CAN, USA'."}]
```

### Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/flipgive_sdk.

## License

This library is distributed under the
[Apache License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html)

```no-highlight
copyright 2023. FlipGive, inc. all rights reserved.

licensed under the apache license, version 2.0 (the "license");
you may not use this file except in compliance with the license.
you may obtain a copy of the license at

    http://www.apache.org/licenses/license-2.0

unless required by applicable law or agreed to in writing, software
distributed under the license is distributed on an "as is" basis,
without warranties or conditions of any kind, either express or implied.
see the license for the specific language governing permissions and
limitations under the license.
```
