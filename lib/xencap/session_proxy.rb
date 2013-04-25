class Xencap::SessionProxy
  def initialize(session, scope)
    @session = session

    if scope.length <= 3
      @scope = scope.upcase
    else
      @scope = scope
    end
  end

  def method_missing(method, *args, &block)
    _request(method, *args)
  end

  def clone(*args)
    if args.length > 0
      _request(:clone, *args)
    else
      super
    end
  end

  def find_all_records(options = {})
    get_all_records.select do |ref, record|
      options.all? do |key, value|
        record[key.to_s] == value
      end
    end
  end

  def find_record(options = {})
    find_all_records(options).first
  end

  def _request(method, *args)
    @session.send(@scope).send(method, *args)
  end
end
