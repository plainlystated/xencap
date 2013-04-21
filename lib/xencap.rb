require File.expand_path(File.dirname(__FILE__) + "/xencap/plugin")

Capistrano.plugin :xencap, Xencap::Plugin
