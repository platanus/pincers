module Pincers::Http
  class BaseDocument

    def uri
      raise NotImplementedError
    end

    def content_type
      raise NotImplementedError
    end

    def content
      raise NotImplementedError
    end

    def save(_path)
      File.write _path, content
    end
  end
end