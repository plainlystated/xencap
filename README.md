# xencap

Capistrano plugin for common xen tasks, using [xenapi](https://github.com/meineerde/xenapi.rb).

## XCP, XenServer
I use [XCP](http://www.xen.org/products/cloudxen.html), so that's what this codebase has been developed against. It probably works with other xen management systems (XenServer, etc), but that hasn't been tested. If you find that it works (or doens't work) with something other than XCP, drop me a note or pull request to update the docs.

## SSL
If your xen server uses a self-signed certificate for its HTTPS site (which is the default for XCP, at least), you'll get an SSL error along the lines of "certificate verify failed". Unfortunately, the xenapi library doesn't provide an easy way to specify the correct SSL certificate), so the only option for now is to use `:ignore_ssl_errors => true` when calling `xencap.setup`. This should only be done in a trusted environment. Someday I hope somebody writes a better xenapi library.