Capistrano::Configuration.instance.load do
  set :xencap_server_uri, nil
  set :xencap_login, "root"
  set :xencap_password, do
    Capistrano::CLI.password_prompt("xen password: ")
  end
  set :xencap_ignore_ssl_errors, false

  on :exit do
    xencap.session.teardown
  end

  namespace :xencap do
    namespace :session do
      task :setup do
        xencap_plugin.setup(
          xencap_server_uri,
          :login => xencap_login,
          :password => xencap_password,
          :ignore_ssl_errors => xencap_ignore_ssl_errors
        )
      end

      task :teardown do
        xencap_plugin.teardown
      end
    end

    namespace :vm do
      task :list do
        xencap.session.setup
        xencap_plugin.vm.get_all_records.reject {|ref, record| record['is_a_template'] || record['is_control_domain'] }.values.each {|v| puts v['name_label'] }
      end
    end
  end
end
