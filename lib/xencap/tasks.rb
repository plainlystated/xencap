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

      task :vnc_tunnel do
        xencap.session.setup
        ip = xencap_server_uri.gsub(%r{^https?://}, '')

        vms = xencap_plugin.vm.get_vms.inject({}) do |out, (vm_ref, params)|
          dom_id = params["domid"]
          out.merge({vm_ref => {:name => params["name_label"], :dom_id => params["domid"]}})
        end

        puts "VMs"
        vms.each do |vm, params|
          puts "  #{params[:dom_id]}: #{params[:name]}"
        end
        puts "Which server would you like to connect to? "
        choice = $stdin.gets.chomp

        valid_choice = vms.map {|vm, params| params[:dom_id]}.include?(choice)
        if valid_choice
          cmd = "ssh root@#{ip} 'xenstore-read /local/domain/#{choice.to_i}/console/vnc-port'"
          port = `#{cmd}`.chomp
          puts "Establishing tunnel to VNC server."
          puts "Use your VNC client to connec to: localhost:#{port}"
          puts "Kill (^c) this when you're done."
          `ssh -N -L #{port}:localhost:#{port} root@#{ip}`
        else
          puts "ERROR: No such VM"
        end
      end
    end
  end
end
