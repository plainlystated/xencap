require File.expand_path(File.dirname(__FILE__) + "/xencap/plugin")
require File.expand_path(File.dirname(__FILE__) + "/xencap/tasks")

Capistrano.plugin :xencap_plugin, Xencap::Plugin
