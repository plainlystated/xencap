class Xencap::SessionProxy::Vm < Xencap::SessionProxy
  def initialize(session)
    @session = session
    @scope = "VM"
  end

  def get_control_dom0
    get_all.select do |vm|
      vm['is_control_domain']
    end
  end

  def get_templates
    get_all.select do |vm|
      vm['is_a_template']
    end
  end

  def get_vms
    get_all.reject do |vm|
      vm['is_a_template'] || vm['is_control_domain']
    end
  end
end
