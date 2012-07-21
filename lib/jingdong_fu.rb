begin
  require "crack"
rescue LoadError
  puts "The Crack gem is not available.\nIf you ran this command from a git checkout " \
       "of Rails, please make sure crack is installed. \n "
  exit
end
# require "patron"
require "digest/md5"
require "yaml"
require "uri"
require "rest"

module JingdongFu

  SANDBOX = 'http://gw.api.sandbox.360buy.com/routerjson?'
  PRODBOX = 'http://gw.api.360buy.com/routerjson?'
  USER_AGENT = 'jingdong_fu/1.1'
  REQUEST_TIMEOUT = 10
  API_VERSION = 2.0
  SIGN_ALGORITHM = 'md5'
  OUTPUT_FORMAT = 'json'

  class << self
    def load(config_file)
      @settings = YAML.load_file(config_file)
      @settings = @settings[Rails.env] if defined? Rails.env
      apply_settings
    end

    def apply_settings
      @base_url = @settings['is_sandbox'] ? SANDBOX : PRODBOX
    end

    def switch_to(sandbox_or_prodbox)
      @base_url = sandbox_or_prodbox
    end

    def get(options = {})
      @response = TaobaoFu::Rest.get(@base_url, generate_query_vars(sorted_params(options)))
      parse_result @response
    end

    def post(options = {})
    end

    def update(options = {})
    end

    def delete(options = {})
    end

    def sorted_params(params)
      method = params.delete(:method)
      param_json = Hash[params.sort_by { |k,v| k.to_s }.map { |k, v| [k.to_s, v.to_s] }].to_json
      {
        :app_key             => @settings['app_key'],
        :access_token        => @settings['access_token'],
        :format              => OUTPUT_FORMAT,
        :v                   => API_VERSION,
        :sign_method         => SIGN_ALGORITHM,
        :timestamp           => Time.now.strftime("%Y-%m-%d %H:%M:%S"),
        :method              => method,
        :'360buy_param_json' => param_json
      }
    end

    def generate_query_vars(params)
      params[:sign] = generate_sign(params.sort_by { |k,v| k.to_s }.flatten.join)
      params
    end

    def generate_sign(param_string)
      Digest::MD5.hexdigest(@settings['secret_key'] + param_string + @settings['secret_key']).upcase
    end

    def parse_result(data)
      Crack::JSON.parse(data)
    end
  end
end