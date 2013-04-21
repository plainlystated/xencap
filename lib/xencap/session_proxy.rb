class Xencap::SessionProxy
  def initialize(session, scope)
    @session = session
    @scope = scope
  end

  def method_missing(method, *args, &block)
    @session.send(@scope).send(method, *args)
  end
end
