require 'zlib'

class CompressionService
  class << self
    def compress(str)
      compressed = Zlib::Deflate.deflate(str.to_json)
      Base64.strict_encode64(compressed)
    end

    def decompress(str)
      data = Base64.strict_decode64(str)
      decompressed_data = Zlib::Inflate.inflate(data)
      JSON.parse(decompressed_data)
    end
  end
end
