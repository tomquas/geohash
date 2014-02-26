begin
  require 'geohash_native'
rescue LoadError => e
  if ENV['JRUBY'] || RUBY_PLATFORM =~ /java/
    require File.expand_path('../geohash_java', __FILE__)
  end
end

class Float
  def decimals(places)
    n = (self * (10 ** places)).round
    n.to_f/(10**places)
  end
end

class GeoHash
  VERSION = '1.2.0'
  NEIGHBOR_DIRECTIONS = [ [0, 1], [2, 3] ]

  # Encode latitude and longitude to a geohash with precision digits
  def self.encode(lat, lon, precision=10)
    encode_base(lat, lon, precision)
  end

  # Decode a geohash to a latitude and longitude with decimals digits
  def self.decode(geohash, decimals=5)
    lat, lon = decode_base(geohash)
    [lat.decimals(decimals), lon.decimals(decimals)]
  end

  # Create a new GeoHash object from a geohash or from a latlon
  def initialize(*params)
    if params.first.is_a?(Float)
      @value = GeoHash.encode(*params)
      @latitude, @longitude = params
    else
      @value = params.first
      @latitude, @longitude = GeoHash.decode(@value)
    end
    @bounding_box = GeoHash.decode_bbox(@value)
  end

  def to_s
    @value
  end

  def to_bbox
    GeoHash.decode_bbox(@value)
  end

  def neighbor(dir)
    GeoHash.calculate_adjacent(@value, dir)
  end

  def neighbors
    immediate = NEIGHBOR_DIRECTIONS.flatten.map do |d|
      neighbor(d)
    end
    diagonals = NEIGHBOR_DIRECTIONS.first.map do |y|
      NEIGHBOR_DIRECTIONS.last.map do |x|
        GeoHash.calculate_adjacent(GeoHash.calculate_adjacent(@value, x), y)
      end
    end.flatten
    immediate + diagonals
  end

  def self._uint64_interleave(lat32, lon32)
    intr = 0
    boost = [0,1,4,5,16,17,20,21,64,65,68,69,80,81,84,85]
    8.times do |i|
      intr = (intr<<8) + (boost[(lon32>>(28-i*4))%16]<<1) + boost[(lat32>>(28-i*4))%16]
    end

    return intr
  end

  def self.encode_uint64(latitude, longitude)
    if latitude >= 90.0 or latitude < -90.0
      raise ValueError("Latitude must be in the range of (-90.0, 90.0)")
    end

    longitude += 360.0 while longitude < -180.0
    longitude -= 360.0 while longitude >= 180.0
    lat = (((latitude + 90.0)/180.0)*(1<<32)).to_i
    lon = (((longitude+180.0)/360.0)*(1<<32)).to_i
    return _uint64_interleave(lat, lon)
  end

  def self._uint64_deinterleave(ui64)
    lat = lon = 0
    boost = [[0,0],[0,1],[1,0],[1,1],[0,2],[0,3],[1,2],[1,3],
             [2,0],[2,1],[3,0],[3,1],[2,2],[2,3],[3,2],[3,3]]
    16.times do |i|
      p = boost[(ui64>>(60-i*4))%16]
      lon = (lon<<2) + p[0]
      lat = (lat<<2) + p[1]
    end

    return [lat, lon]
  end

    def self.decode_uint64(ui64)
      # if _geohash
      #     latlon = _geohash.decode_int(ui64 % 0xFFFFFFFFFFFFFFFF, LONG_ZERO)
      #     if latlon
      #         return latlon

      lat,lon = _uint64_deinterleave(ui64)
      return [180.0*lat/(1<<32) - 90.0, 360.0*lon/(1<<32) - 180.0]
    end
  end
