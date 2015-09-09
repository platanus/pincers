require 'rubygems'
require 'rack'

module Pincers
  module Test
    class Server
      def call(env)
        @root = FIXTURE_PATH
        path = Rack::Utils.unescape(env['PATH_INFO'])
        path += 'index.html' if path == '/'
        file = File.join(@root, path)

        if File.exists?(file)
          [ 200, {"Content-Type" => "text/html"}, File.read(file) ]
        elsif !respond_to? path[1..-1]
          [ 404, {'Content-Type' => 'text/plain'}, 'file not found' ]
        else
          req = Rack::Request.new(env)
          send(path[1..-1], req, req.params)
        end
      end

      # Some testing endpoints

      def echo(_req, _params)
        [
          200, {
            "Content-Type" => "text/plain"
          },
          _params['text']
        ]
      end

      def submit(_req, _params)
        [
          200, {
            "Content-Type" => "text/html"
          },
          "<html><body>#{_req.body.read}</body></html>"
        ]
      end

      def setcookie(_req, _params)
        [
          200, {
            "Content-Type" => "text/plain",
            "Set-Cookie" => "#{_params['name']}=#{_params['value']}"
          },
          'Logged in!'
        ]
      end

      def checkcookie(_req, _params)
        if _req.cookies[_params['name']] == _params['value']
          [ 200, {"Content-Type" => "text/plain"}, 'Authorized!' ]
        else
          [ 401, {"Content-Type" => "text/plain"}, 'Unauthorized!' ]
        end
      end
    end
  end
end