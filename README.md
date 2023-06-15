# FlipgiveSDK

## Shop Cloud

Shop Cloud _(The Shop)_ is [FlipGive's](https://www.flipgive.com) drop-in cashback store. If you would like to know more please visit www.flipgive.com/cloud or contact us at partners@flipgive.com.

### Links of Interest

- [FlipGive](https://www.flipgive.com)
- [API Documentation](https://docs.flipgive.com)

### Installation

To begin using `FlipGiveSDK::ShopCloud`, you should have obtained an `ID` and `Secret` pair from FlipGive, store these securely so that they are accessible in your application (env variables, rails credentials, etc). We'll be using env variables in our example below. If you haven't received credentials, please contact us at partners@flipgive.com.

Add the gem to your Gemfile:

```ruby
gem 'flipgive_sdk', git: "https://github.com/BetterTheWorld/FlipGiveSDK_Ruby.git"
```

After you have installed the gem include the code below to initialize the ShopCloud:

```ruby
FlipgiveSDK::ShopCloud.flip(ENV['shop_cloud_id'], ENV['shop_cloud_secret'])
```
We recommend using its own initializer file `myapp/config/initializers/shop_cloud.rb`.

ShopCloud is now ready to use.

### Usage

The main purpose of `FlipgiveSDK::ShopCloud` is to generate Tokens to gain access to FlipGive's Shop Cloud API. There are 6 methods on the gem's public API.

#### :flip
This method is used to initialize the SDK, as described on the setup section of this document. It takes 2 arguments, the `shop_cloud_id` and the `shop_cloud_Secret`.

#### :read_token
This method is used to decode a token that has been generated with your credentials. It takes a single string as an argument and, if able to decode the token, it will return a hash.

```ruby
token = "eyJhbGciOiJkaXIiLCJlbmMiOiJBMTI4R0NNIn0..demoToken.g8PZPWb1KDFcAkTsufZq0w@A2DE537C"

FlipgiveSDK::ShopCloud.read_token(token)
=> { user_data: { id: 1, name: 'Emmett Brown', email: 'ebrown@time.ca', country: 'USA' } }
```

#### :identified_token
This method is used to generate a token that will identify a user or campaign. It accepts a **Payload Hash** as an argument and it returns an encrypted token. 

```ruby
payload = {
  user_data: user_data,
  campaign_data: campaign_data,
  group_data: group_data,
  organization_data: organization_data
}

FlipgiveSDK::ShopCloud.identified_token(payload)
=> "eyJhbGciOiJkaXIiLCJlbmMiOiJBMTI4R0NNIn0..demoToken.g8PZPWb1KDFcAkTsufZq0w@A2DE537C"
```

The variable in this example uses other variables, (user_data, campaign_data, etc.). let's look at each one of them:

- `user_data`: **required** when `campaign_data` is not present in the payload, otherwise optional. It represents the user using the Shop, and  contains the following information:
  - `id`: **required**. A string representing the user's ID in your system.
  - `email`: **required**. A string with the user's email.
  - `name`: **required**. A string with the user's name.
  - `country`: **required**. A string with the ISO code of the user's country, which must be 'CAN' or 'USA' at this time.
  - `city`: *optional*. A string with the user's city.
  - `state`: *optional*. A string with the user's state. It must be a 2 letter code. You can see a list of values [here](https://github.com/BetterTheWorld/FlipGiveSDK_Ruby/blob/main/states.yml).
  - `postal_code`: A string with the user's postal code. It must match Regex `/\d{5}/` for the USA or `/[a-zA-Z]\d[a-zA-Z]\d[a-zA-Z]\d/` for Canada.
  - `latitude`: *optional*. A float with the user's latitude in decimal degree format. Without accompanying `:longitude`, latitude will be ignored.
  - `longitude`: *optional*. A float with the user's longitude in decimal degree format. Without accompanying `:latitude`, longitude will be ignored.
  - `image_url`: *optional*. A string containing the URL for the user's avatar.

  ```ruby
  user_data = {
    id: 19850703,
    name: 'Emmett Brown',
    email: 'ebrown@time.com',
    country: 'USA'
  }
  ```
Optional fields of invalid formats will not be validated but will be ignored.

- `campaign_data`: Required when user_data is not present in the payload, otherwise optional. It represents the fundraising campaign and contains the following information:

  - `id`: **required** A string representing the user's ID in your system.
  - `name`: **required** A string  with the campaign's email.
  - `category`: **required** A string  with the campaign's category. We will try to match it with one of our existing categories, or assign a default. You can see a list of our categories [here](https://github.com/BetterTheWorld/FlipGiveSDK_Ruby/blob/main/categories.txt).
  - `country`: **required** A string  with the ISO code of the campaign's country, which must be 'CAD' or 'USA' at this time.
  - `admin_data`: **required** The user information for the campaign's admin. It must contain the same information as `user_data`
  - `city`: *optional*. A string with the campaign's city.
  - `state`: *optional*. A string with the campaign's state. It must be a 2 letter code. You can see a list [here](https://github.com/BetterTheWorld/FlipGiveSDK_Ruby/blob/main/states.yml).
  - `postal_code`: A string with the campaign's postal code. It must match Regex `/\d{5}/` for the USA or `/[a-zA-Z]\d[a-zA-Z]\d[a-zA-Z]\d/` for Canada.
  - `latitude`: *optional*. A float with the campaign's latitude in decimal degree format.
  - `longitude`: *optional*. A float with the campaign's longitude in decimal degree format.
  - `image_url`: *optional*. A string containing the URL for the campaign's image, if any.

Optional fields of invalid formats will not be validated but will be ignored.

  ```ruby
  campaign_data = {
    id: 19551105,
    name: 'The Time Travelers',
    category: 'Events & Trips',
    country: 'USA',
    admin_data: user_data
  }
  ```

- `group_data`: *Always optional*. Groups are aggregators for users within a campaign. For example, a group can be a Player on a sport's team and the users would be the people supporting them.
  - `name`: **required**. A string with the group's name.
  - `player_number`: *optional*. A sport's player number on the team.

  ```ruby
  group_data = { 
    name: 'Marty McFly' 
  }
  ```

- `organization_data`: Always optional. Organizations are used to group campaigns. As an example: A School (organization) has many Grades (campaigns), with Students (groups) and Parents (users) shopping to support their student.
  - `id`: **required**. A string with the organization's ID.
  - `name`: **required**. A string with the organization's name.
  - `organization_admin`: **required**. The user information for the organization's admin. It must contain the same information as `user_data`

  ```ruby
  organization_data = {
    id: 980,
    name: 'Back to the Future',
    admin_data: user_data
  }
  ```

#### :valid_identified?
This method is used to validate a payload, without attempting to generate a token. It returns a Boolean. The same rules for `:identified_token` apply here as well.

```ruby
payload = { 
  user_data: user_data 
}

FlipgiveSDK::ShopCloud.valid_identified?(payload)
=> true
```

#### :partner_token
This method is used to generate a token that can **only** be used by the Shop Cloud partner (that's you) to access reports and other API endpoints. It is only valid for an hour. 

```ruby
FlipgiveSDK::ShopCloud.partner_token
=> "eyJhbGciOiJkaXIiLCJlbmMiOiJBMTI4R0NNIn0..demoToken.h9QXQEn2LFGVSlTdiGXW1e@A2DE537C"
```

#### :errors
Validation errors that occur while attempting to generate a token can be retrieved here.

```ruby
user_data[:country] = 'ENG'

payload = { 
  user_data: user_data 
}

FlipgiveSDK::ShopCloud.valid_identified?(payload)

# FlipgiveSDK::Error (Invalid payload.)

FlipgiveSDK::ShopCloud.errors

=> [{:user_data=>"Country must be one of: 'CAN, USA'."}]
```

### Support

For developer support please open an [issue](https://github.com/BetterTheWorld/FlipGiveSDK_Ruby/issues) on this repository.

### Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/BetterTheWorld/flipgive_sdk](https://github.com/BetterTheWorld/flipgive_sdk).

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
