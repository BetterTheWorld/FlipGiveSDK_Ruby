# frozen_string_literal: true

require "flipgive_sdk"
require "faker"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

class RewardsHelper
  class << self
    def person_data
      nom = Faker::Movies::StarWars.character
      {
        "id" => rand(100_000..999_999),
        "name" => nom,
        "email" => email(nom),
        "country" => "CAN"
      }
    end

    def campaign_data
      {
        "id" => rand(100_000..999_999),
        "name" => Faker::Movies::StarWars.call_sign,
        "category" => "Running",
        "country" => "CAN",
        "admin_data" => person_data
      }
    end

    def group_data
      {
        "name" => Faker::Movies::StarWars.droid
      }
    end

    def organization_data
      {
        "id" => rand(100_000..999_999),
        "name" => "The #{Faker::Movies::StarWars.vehicle}s",
        "admin_data" => person_data
      }
    end

    def division_data
      {
        "id" => rand(100_000..999_999),
        "name" => "#{Faker::Movies::StarWars.planet} chapter",
        "admin_data" => person_data,
        "category" => "Running",
        "country" => "CAN"
      }
    end

    private

    def email(nom)
      nom = nom.downcase.gsub(" ", "_")
      planet = Faker::Movies::StarWars.planet.downcase.gsub(" ", "_")
      "#{nom}@#{planet}.com"
    end
  end
end
