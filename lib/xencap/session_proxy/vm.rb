class Xencap::SessionProxy::Vm < Xencap::SessionProxy
  def initialize(session)
    @session = session
    @scope = "VM"
  end

  def get_control_dom0
    get_all_records.select do |vm|
      vm['is_control_domain']
    end
  end

  def get_templates
    get_all_records.select do |vm|
      vm['is_a_template']
    end
  end

  def get_vms
    get_all_records.reject do |vm, params|
      params['is_a_template'] || params['is_control_domain']
    end
  end

  def clone_template(template_name, name)
    template_ref, template_record = get_all_records.detect do |ref, record|
      record['is_a_template'] == true && record['name_label'] == template_name
    end
    ref = clone(template_ref, name)
    set_is_a_template(ref, false)
    ref
  end
end
