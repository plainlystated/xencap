require 'xencap/xenapi'

module Xencap
  module Plugin
    attr_reader :session

    def setup(uri, options = {})
      @session = XenAPI::Session.new(uri)

      _ignore_ssl_errors if options.fetch(:ignore_ssl_errors, false)

       @session.login_with_password(options.fetch(:login), options.fetch(:password))

       metaclass = class << self; self; end
       @session_proxies = ["VM"].each do |scope|
         metaclass.send(:define_method, scope.downcase) do
           Xencap::SessionProxy.new(@session, scope)
         end
       end
    end

    def teardown
      @session.logout
    end

    def _ignore_ssl_errors
      # Allow self-signed certs
      @session.instance_variable_get(:@http).instance_variable_set(:@verify_mode, OpenSSL::SSL::VERIFY_NONE)
    end
  end
end
