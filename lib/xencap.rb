module Xencap
  require File.expand_path('../xencap/tasks', __FILE__)

  autoload :Plugin, File.expand_path('../xencap/plugin', __FILE__)
  autoload :SessionProxy, File.expand_path('../xencap/session_proxy', __FILE__)
end

Capistrano.plugin :xencap_plugin, Xencap::Plugin
