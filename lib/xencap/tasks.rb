Capistrano::Configuration.instance.load do
  set :xencap_server_uri, nil
  set :xencap_login, "root"
  set :xencap_password, nil
  set :xencap_ignore_ssl_errors, false

  on_rollback do
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
  end
end
