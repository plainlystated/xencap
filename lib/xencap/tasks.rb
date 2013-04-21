Capistrano::Configuration.instance.load do
  on_rollback do
    xencap.session.teardown
  end

  namespace :xencap do
    namespace :session do
      task :teardown do
        xencap_plugin.teardown
      end
    end
  end
end
