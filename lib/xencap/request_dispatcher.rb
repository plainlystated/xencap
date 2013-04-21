class Xencap::RequestDispatcher
  def initialize(session)
    @session = session
    @proxy_classes = Dir[File.expand_path("../session_proxy/*rb", __FILE__)]
    @proxies = {}

  end

  def dispatch(scope, *args)
    if @proxies.has_key?(scope)
      # nothing to do here
    elsif filename = @proxy_classes.detect {|file| File.basename(file, ".rb").downcase == scope.to_s}
      require filename
      @proxies[scope] = Xencap::SessionProxy.const_get(scope.capitalize).new(@session)
    else
      @proxies[scope] = Xencap::SessionProxy.new(@session, scope)
    end

    @proxies[scope]
  end
end
