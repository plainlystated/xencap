require 'xencap/xenapi'

module Xencap
  module Plugin
    def setup(uri, options = {})
      @session = XenAPI::Session.new(uri)

      _ignore_ssl_errors if options.fetch(:ignore_ssl_errors, false)

      begin
       @session.login_with_password(options.fetch(:login), options.fetch(:password))
        vms = @session.VM.get_all
        vms.each do |vm|
          record = @session.VM.get_record(vm)
          unless record['is_a_template'] || record['is_control_domain']
            name = record['name_label']
            puts "Found VM uuid #{record['uuid']} called #{name}"
          end
        end
      ensure
        teardown
      end
    end

    def teardown
      @session.logout
      puts "session logged out"
    end

    def _ignore_ssl_errors
      # Allow self-signed certs
      @session.instance_variable_get(:@http).instance_variable_set(:@verify_mode, OpenSSL::SSL::VERIFY_NONE)
    end
  end
end
