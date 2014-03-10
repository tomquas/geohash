#!/usr/bin/env ruby
$LOAD_PATH << "#{File.dirname(__FILE__)}/../ext"
require "#{File.dirname(__FILE__)}/../lib/geohash"
require 'test/unit'

class GeoHashTest < Test::Unit::TestCase

  def test_lat_lon
    dataset = [
      [0x0000000000000000, -90.0, -180.0],
      [0x0800000000000000, -90.0, -135.0],
      [0x1000000000000000, -45.0, -180.0],
      [0x1800000000000000, -45.0, -135.0],
      [0x2000000000000000, -90.0, -90.0],
      [0x2800000000000000, -90.0, -45.0],
      [0x3000000000000000, -45.0, -90.0],
      [0x3800000000000000, -45.0, -45.0],
      [0x4000000000000000, 0.0, -180.0],
      [0x4800000000000000, 0.0, -135.0],
      [0x5000000000000000, 45.0, -180.0],
      [0x5800000000000000, 45.0, -135.0],
      [0x6000000000000000, 0.0, -90.0],
      [0x6800000000000000, 0.0, -45.0],
      [0x7000000000000000, 45.0, -90.0],
      [0x7800000000000000, 45.0, -45.0],
      [0x8000000000000000, -90.0, 0.0],
      [0x8800000000000000, -90.0, 45.0],
      [0x9000000000000000, -45.0, 0.0],
      [0x9800000000000000, -45.0, 45.0],
      [0xA000000000000000, -90.0, 90.0],
      [0xA800000000000000, -90.0, 135.0],
      [0xB000000000000000, -45.0, 90.0],
      [0xB800000000000000, -45.0, 135.0],
      [0xC000000000000000, 0.0, 0.0],
      [0xC800000000000000, 0.0, 45.0],
      [0xD000000000000000, 45.0, 0.0],
      [0xD800000000000000, 45.0, 45.0],
      [0xE000000000000000, 0.0, 90.0],
      [0xE800000000000000, 0.0, 135.0],
      [0xF000000000000000, 45.0, 90.0],
      [0xF800000000000000, 45.0, 135.0]
    ]

    dataset.each do |data|
      assert_equal data[0], GeoHash.encode_uint64(data[1], data[2])
      latlon = GeoHash.decode_uint64(data[0])
      assert_equal data[1], latlon[0]
      assert_equal data[2], latlon[1]
    end
  end

  def test_geohash
    data = [0xC800000000000000, 0.0, 45.0]
    geohash = GeoHash.encode(data[1], data[2])

    # converting geohash to lat/lon introduces rounding errors, so result
    # is not exactly data[0]
    expected_after_rounding = 14027211639383294080
    assert_equal expected_after_rounding, GeoHash.encode_uint64(geohash)
    assert_equal expected_after_rounding, GeoHash.encode_uint64(data[1], data[2] - 1e-5)
  end
end
