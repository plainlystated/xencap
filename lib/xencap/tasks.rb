Capistrano::Configuration.instance.load do
  set :xencap_server_ip, nil
  set :xencap_server_uri, do
    "http://#{xencap_server_ip}"
  end
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

    namespace :iso_lib do
      task :create, :role => :xenserver do
        xencap.session.setup
        name = "ISO Library"
        run "mkdir -p /var/lib/isos"

        sr_ref, sr_record = xencap_plugin.sr.find_record(:name_label => name)
        if sr_ref
          puts "#{name}already exists. Exiting."
          exit
        end

        host_ref, host = xencap_plugin.host.find_all_records.first

        puts "Creating Storge Repository..."
        sr_ref = xencap_plugin.sr.create(host_ref, {"location" => "/var/lib/isos", "legacy_mode" => "true"}, "1", name, "", "iso", "iso", false)
        puts "Created. Add images to /var/lib/isos/"
      end

      task :scan do
        xencap.session.setup
        sr_ref, sr_record = xencap_plugin.sr.find_record(:name_label => "ISO Library")
        xencap_plugin.sr.scan(sr_ref)
      end
    end

    namespace :vm do
      task :list do
        xencap.session.setup
        xencap_plugin.vm.get_all_records.reject {|ref, record| record['is_a_template'] || record['is_control_domain'] }.values.each {|v| puts v['name_label'] }
      end

      task :vnc_tunnel do
        xencap.session.setup
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
          cmd = "ssh root@#{xencap_server_ip} 'xenstore-read /local/domain/#{choice.to_i}/console/vnc-port'"
          port = `#{cmd}`.chomp
          puts "Establishing tunnel to VNC server."
          puts "Use your VNC client to connec to: localhost:#{port}"
          puts "Kill (^c) this when you're done."
          `ssh -N -L #{port}:localhost:#{port} root@#{xencap_server_ip}`
        else
          puts "ERROR: No such VM"
        end
      end
    end
  end
end
