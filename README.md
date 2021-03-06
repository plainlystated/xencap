# xencap

A [capistrano](https://github.com/capistrano/capistrano) plugin for common xen tasks, using [xenapi](https://github.com/meineerde/xenapi.rb).

## XCP, XenServer, XAPI
This library should work with any xen system running XAPI as the toolstack. This is the default on XenServer and [XCP](http://www.xen.org/products/cloudxen.html).

## Terminology
If you're not already familiar with xen terminology (VIF, PBD, SR, etc), you should familiarize yourself with it, as those terms are used in this library. There's a handy overview in the [XenServer docs](http://docs.vmd.citrix.com/XenServer/6.0.0/1.0/en_gb/sdk.html#object_model_overview), though the terms apply to xen in general (xen, XCP, XenServer).

## Hiding Complexity
Xen is a complex project, and a running xen system has lots of moving parts (see Terminology, above). It is not the intent of this project to abstract away that complexity, but rather to allow automated management of it (in a version-controllable way).

## Example Usage
There are a couple example tasks defined (eg `xencap:vm:list`), but to do anything meaningful you'll want to write your own. The following task (`xencap:vm:create:ubuntu_12_04`) uses a template (ubuntu 12.04 LTS) to create a new domain. It creates a VDI (virtual disk), a VBD (virtual block device, on the VDI), a VIF (Virtual Interface, on the local network), and puts it all on a new VM. It then starts the VM.
```ruby
$: << File.expand_path(File.dirname(__FILE__) + "/../lib/vycap/lib" # until there's a proper gem
require 'vycap'

set :xencap_server_uri, "http://192.168.1.123"
namespace :xencap do
  namespace :vm do
    namespace :create do
      task :ubuntu_12_04 do
        xencap.session.setup
        hostname = "host.domain.tld"

        vm_ref = xencap_plugin.vm.clone_template("Ubuntu Precise Pangolin 12.04 (64-bit)", hostname)
        xencap_plugin.vm.add_to_other_config(vm_ref, "install-repository", "http://us.archive.ubuntu.com/ubuntu/")

        sr_ref, sr_record = xencap_plugin.sr.find_record(:name_label => "Local storage")
        vdi_ref = xencap_plugin.vdi.create(
          :name_label => hostname,
          :SR => sr_ref,
          :virtual_size => "10737418240",
          :type => "System",
          :sharable => false,
          :read_only => false,
          :other_config => {}
        )

        vbd_ref = xencap_plugin.vbd.create(
          :VM => vm_ref,
          :VDI => vdi_ref,
          :device => "xvda",
          :userdevice => "xvda",
          :bootable => true,
          :mode => "rw",
          :type => "disk",
          :empty => false,
          :other_config => {},
          :qos_algorithm_type => "",
          :qos_algorithm_params => {}
        )

        network_ref, network_record = xencap_plugin.network.find_record(:bridge => "xenbr0")
        vif_ref = xencap_plugin.vif.create(
          :network => network_ref,
          :VM => vm_ref,
          :device => "0",
          :MAC => "",
          :MTU => "1500",
          :other_config => {},
          :qos_algorithm_type => "",
          :qos_algorithm_params => {}
        )

        puts xencap_plugin.vm.start(vm_ref, false, false)
      end
    end
  end
end
```

## Docs
This plugin is a light-weight wrapper around xenapi, which unfortunately isn't well documented. I use [this PDF](http://support.citrix.com/servlet/KbServlet/download/25589-102-666255/xenenterpriseapi.pdf) as a reference.

## SSL
If your xen server uses a self-signed certificate for its HTTPS site (which is the default for XCP, at least), you'll get an SSL error along the lines of "certificate verify failed". Unfortunately, the xenapi library doesn't provide an easy way to specify the correct SSL certificate), so the only option for now is to use `:ignore_ssl_errors => true` when calling `xencap.setup`. This should only be done in a trusted environment. Someday I hope somebody writes a better xenapi library.
