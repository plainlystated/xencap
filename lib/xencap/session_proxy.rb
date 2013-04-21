class Xencap::SessionProxy
  def initialize(session, scope)
    @session = session
    @scope = scope
  end

  def method_missing(method, *args, &block)
    _request(method, *args)
  end

  def get_all
    _request(:get_all).map do |sid|
      get_record(sid)
    end
  end

  def _request(method, *args)
    @session.send(@scope).send(method, *args)
  end
end
