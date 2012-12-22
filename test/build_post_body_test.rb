require_relative '../lib/rack/signature/build_post_body'
require_relative '../lib/rack/signature/sort_query_params'
require 'test_helper'

module Rack::Signature
  class BuildPostBodyTest < MiniTest::Unit::TestCase
    include TestHelper

    def hash
      @hash ||= JSON.parse(read_json('data'))
    end

    def build
      BuildPostBody.new(hash)
    end

    def test_sorting_data
      expected = {"fitting"=>{"club_swing_data"=>[{"driver"=>{"backspin"=>"2", "ball_speed"=>"a", "deviation_angle"=>"2.3", "launch_angle"=>"3.2", "mode"=>"b", "slidespin"=>"1"}}], "distributor"=>"Big 5", "golfer"=>{"agreedToPromotion"=>"false", "country"=>"USA", "email"=>"mice@mice.com", "firstName"=>"Johnny", "gender"=>"male", "lastName"=>"Bravo", "zipcode"=>"938383"}, "location"=>[32.694866, -116.630859], "measurements"=>{"clubPreferences"=>{"shaftFlexDriver"=>"b"}, "golfer"=>{"handicap"=>"8", "height"=>"6.1", "rightHanded"=>"true", "roundsPerMonth"=>"9", "shotShape"=>"b"}}, "recommendations"=>[{"adjustments"=>{"face_angle"=>"angle", "loft"=>"f", "shaft_flex"=>"shaft flex", "shaft_model"=>"club", "shot_shape"=>"circle"}, "club_name"=>"g", "sku"=>"h"}], "trajectory"=>{"carry"=>"two", "coordinates"=>[{"time"=>"12345", "x"=>"3.1", "y"=>"2.1", "z"=>"1.1"}], "deviation"=>"one", "peakHeight"=>"tree"}}}

      assert_equal expected, build.sort_post_body
    end

  end
end
