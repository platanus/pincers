module Pincers::Core
  class Download < Struct.new(:mime, :data)

    def self.from_http_response(_response)
      self.new _response['Content-Type'] || 'text/plain', _response.body
    end

    def store(_path)
      File.write _path, data
    end

  end
end