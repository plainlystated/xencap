require 'xencap/xenapi'

module Xencap
  module Plugin
    attr_reader :session, :request_dispatcher

    def setup(uri, options = {})
      @session = XenAPI::Session.new(uri)
      _ignore_ssl_errors if options.fetch(:ignore_ssl_errors, false)

       @session.login_with_password(options.fetch(:login), options.fetch(:password))
       @request_dispatcher = Xencap::RequestDispatcher.new(@session)
    end

    def teardown
      @session.logout unless @session.nil?
    end

    def method_missing(method, *args)
      @request_dispatcher.dispatch(method, *args)
    end

    def _ignore_ssl_errors
      # Allow self-signed certs
      @session.instance_variable_get(:@http).instance_variable_set(:@verify_mode, OpenSSL::SSL::VERIFY_NONE)
    end
  end
end
