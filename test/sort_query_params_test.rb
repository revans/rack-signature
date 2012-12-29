require_relative '../lib/rack/signature/sort_query_params'
require_relative 'test_helper'
require 'json'

module Rack::Signature
  describe SortQueryParams do
    include TestHelper

    it 'will sort a loaded json file' do
      json = read_json('data')
      hash = JSON.parse(json)

      ordered_json = read_json('ordered_json_data')
      ordered_json_hash = JSON.parse(ordered_json)

      assert_equal ordered_json_hash, SortQueryParams.new(hash).order
    end

    it 'will sort a large data set' do
      assert_equal expected_data, SortQueryParams.new(actual_data).order
    end

    it 'will sort a simple hash by keys only' do
      expected = { age: 99, first_name: 'john', last_name: 'smith'}
      assert_equal expected, SortQueryParams.new({last_name: 'smith', first_name: 'john', age: 99}).order
    end

    it 'will handle a simple array' do
      actual    = {"location" => [32, 34], "angle" => 3 }
      expected  = {"angle" => 3, "location" => [32, 34] }

      assert_equal expected, SortQueryParams.new(actual).order
    end

    it 'can handle multiple keys of the same name when sorting' do
      actual    = { data: [ {person: { name: 'john', age: 12 }}, {person: { name: 'bill', age: 77 }}]}
      expected  = { data: [ {person: { age: 12, name: 'john' }}, {person: { age: 77, name: 'bill' }}]}

      assert_equal expected, SortQueryParams.new(actual).order
    end

    it 'will sort array of hashes' do
      actual = {
        "recommendations" => [{
          "sku"         =>"h",
          "club_name"   =>"g",
          "adjustments" => {
            "shaft_model" => "club",
            "shot_shape"  => "circle",
            "shaft_flex"  => "shaft flex",
            "loft"        => "f",
            "face_angle"  => "angle",
          },
        }],
        "distributor" => "Big 5",
        "golfer" => {
          "agreedToPromotion" =>"false",
          "country"           =>"USA",
          "email"             =>"mice@mice.com",
          "firstName"         =>"Johnny",
          "gender"            =>"male",
          "lastName"          =>"Bravo",
          "zipcode"           =>"938383"
        },
      }
      expected = {
        "distributor" => "Big 5",
        "golfer" => {
          "agreedToPromotion" =>"false",
          "country"           =>"USA",
          "email"             =>"mice@mice.com",
          "firstName"         =>"Johnny",
          "gender"            =>"male",
          "lastName"          =>"Bravo",
          "zipcode"           =>"938383"
        },
        "recommendations" => [{
          "adjustments" => {
            "face_angle"  => "angle",
            "loft"        => "f",
            "shaft_flex"  => "shaft flex",
            "shaft_model" => "club",
            "shot_shape"  => "circle",
          },
          "club_name"   =>"g",
          "sku"         =>"h"
        }]
      }

      assert_equal expected, SortQueryParams.new(actual).order
    end

    it 'will sort a rooted hash' do
      actual = {
        "fitting" => {
          "measurements"  => {
            "golfer"          => {
              "shotShape"       =>"b",
              "height"          =>"6.1",
              "rightHanded"     =>"true",
              "roundsPerMonth"  =>"9",
              "handicap"        =>"8"
            },
            "clubPreferences" => {"shaftFlexDriver"=>"b"}
          },
          "club_swing_data" =>
          [{
            "driver" => {
              "slidespin"       =>"1",
              "ball_speed"      =>"a",
              "mode"            =>"b",
              "launch_angle"    =>"3.2",
              "deviation_angle" =>"2.3",
              "backspin"        =>"2"
            }}]
        }}

        expected = {
          "fitting" => {
            "club_swing_data" =>
            [{
              "driver" => {
                "backspin"        =>"2",
                "ball_speed"      =>"a",
                "deviation_angle" =>"2.3",
                "launch_angle"    =>"3.2",
                "mode"            =>"b",
                "slidespin"       =>"1"
              }}],
              "measurements"  => {
                "clubPreferences" => {"shaftFlexDriver"=>"b"},
                "golfer"          => {
                  "handicap"        =>"8",
                  "height"          =>"6.1",
                  "rightHanded"     =>"true",
                  "roundsPerMonth"  =>"9",
                  "shotShape"       =>"b"
                }
              }
          }}

          assert_equal expected, SortQueryParams.new(actual).order
    end


    def expected_data
      {"fitting" => {
        "club_swing_data" => [
          {
            "driver" => {
              "backspin"        =>"2",
              "ball_speed"      =>"a",
              "deviation_angle" =>"2.3",
              "launch_angle"    =>"3.2",
              "mode"            =>"b",
              "slidespin"       =>"1"
            }}
        ],
          "distributor" => "Big 5",
          "golfer" => {
            "agreedToPromotion" =>"false",
            "country"           =>"USA",
            "email"             =>"mice@mice.com",
            "firstName"         =>"Johnny",
            "gender"            =>"male",
            "lastName"          =>"Bravo",
            "zipcode"           =>"938383"
          },
          "location"      => [32.694866, -116.630859],
          "measurements"  => {
            "clubPreferences" => {"shaftFlexDriver"=>"b"},
            "golfer"          => {
              "handicap"        =>"8",
              "height"          =>"6.1",
              "rightHanded"     =>"true",
              "roundsPerMonth"  =>"9",
              "shotShape"       =>"b"
            }
          },
          "recommendations" => [{
            "adjustments" => {
              "face_angle"  => "angle",
              "loft"        => "f",
              "shaft_flex"  => "shaft flex",
              "shaft_model" => "club",
              "shot_shape"  => "circle",
            },
            "club_name"   =>"g",
            "sku"         =>"h"
          }]
      }}
    end

    def actual_data
      {"fitting" => {
        "golfer" => {
          "firstName"         =>"Johnny",
          "email"             =>"mice@mice.com",
          "agreedToPromotion" =>"false",
          "zipcode"           =>"938383",
          "lastName"          =>"Bravo",
          "gender"            =>"male",
          "country"           =>"USA",
        },
        "measurements"  => {
          "clubPreferences" => {"shaftFlexDriver"=>"b"},
          "golfer"          => {
            "rightHanded"     =>"true",
            "height"          =>"6.1",
            "roundsPerMonth"  =>"9",
            "shotShape"       =>"b",
            "handicap"        =>"8",
          }
        },
        "location"      => [32.694866, -116.630859],
        "recommendations" => [{
          "club_name"   =>"g",
          "adjustments" => {
            "shot_shape"  => "circle",
            "loft"        => "f",
            "shaft_model" => "club",
            "shaft_flex"  => "shaft flex",
            "face_angle"  => "angle",
          },
          "sku"         =>"h"
        }
        ],
          "distributor" => "Big 5",
          "club_swing_data" => [
            {
              "driver" => {
                "backspin"        =>"2",
                "ball_speed"      =>"a",
                "deviation_angle" =>"2.3",
                "launch_angle"    =>"3.2",
                "mode"            =>"b",
                "slidespin"       =>"1"
              }}
          ]
      }}
    end

  end
end

