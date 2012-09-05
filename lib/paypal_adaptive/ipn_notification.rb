require 'net/http'
require 'net/https'
require 'json'

module PaypalAdaptive
  class IpnNotification

    def initialize(env=nil)
      config = PaypalAdaptive.config(env)
      @paypal_base_url = config.paypal_base_url
      @ssl_cert_path = config.ssl_cert_path
      @ssl_cert_file = config.ssl_cert_file
    end

    def send_back(data)
      data = "cmd=_notify-validate&#{data}"
      url = URI.parse @paypal_base_url
      http = Net::HTTP.new(url.host, 443)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.ca_path = "/etc/ssl/certs" #@ssl_cert_path unless @ssl_cert_path.nil?
      
      if @ssl_cert_file
        # cert = File.read(@ssl_cert_file)
        # http.cert = OpenSSL::X509::Certificate.new(cert)
        # http.key = OpenSSL::PKey::RSA.new(cert)
        http.ca_file = @ssl_cert_file
      end

      path = "#{@paypal_base_url}/cgi-bin/webscr"
      response_data = http.post(path, data).body

      @verified = response_data == "VERIFIED"
    end

    def verified?
      @verified
    end

  end
end
