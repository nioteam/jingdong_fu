require "uri"
require "net/http"

module JingdongFu
  module Rest
    class << self
      def get(url, hashed_vars)
        res = request(url, 'GET', hashed_vars)
        process_result(res, url)
      end

      def post(url, hashed_vars)
        res = request(url, 'POST', hashed_vars)
        process_result(res, url)
      end

      def put(url, hashed_vars)
        res = request(url, 'PUT', hashed_vars)
        process_result(res, url)
      end

      def delete(url, hashed_vars)
        res = request(url, 'DELETE', hashed_vars)
        process_result(res, url)
      end

      protected

        def request(url, method=nil, params = {})
          if !url || url.length < 1
            raise ArgumentError, 'Invalid url parameter'
          end
          if method && !['GET', 'POST', 'DELETE', 'PUT'].include?(method)
            raise NotImplementedError, 'HTTP %s not implemented' % method
          end

          if method && method == 'GET'
            url = build_get_uri(url, params)
          end
          uri = URI.parse(url)

          http = Net::HTTP.new(uri.host, uri.port)

          if method && method == 'GET'
            req = Net::HTTP::Get.new(uri.request_uri)
          elsif method && method == 'DELETE'
            req = Net::HTTP::Delete.new(uri.request_uri)
          elsif method && method == 'PUT'
            req = Net::HTTP::Put.new(uri.request_uri)
            req.set_form_data(params)
          else
            req = Net::HTTP::Post.new(uri.request_uri)
            req.set_form_data(params)
          end

          http.request(req)
        end

        def build_get_uri(uri, params)
          if params && params.length > 0
            uri += '?' unless uri.include?('?')
            uri += urlencode(params)
          end
          URI.escape(uri)
        end

        def urlencode(params)
          params.to_a.collect! { |k, v| "#{k.to_s}=#{v.to_s}" }.join("&")
        end

        def process_result(res, raw_url)
          if res.code =~ /\A2\d{2}\z/
            res.body
          elsif %w(301 302 303).include? res.code
            url = res.header['Location']
            if url !~ /^http/
              uri = URI.parse(raw_url)
              uri.path = "/#{url}".squeeze('/')
              url = uri.to_s
            end
            raise RuntimeError, "Redirect #{url}"
          elsif res.code == "304"
            raise RuntimeError, "NotModified #{res}"
          elsif res.code == "401"
            raise RuntimeError, "Unauthorized #{res}"
          elsif res.code == "404"
            raise RuntimeError, "Resource not found #{res}"
          else
            raise RuntimeError, "Maybe request timed out #{res}. HTTP status code #{res.code}"
          end
        end

    end
  end
end
