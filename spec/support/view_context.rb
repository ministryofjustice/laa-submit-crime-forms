module ViewContext
  def build_view_context(current_application, virtual_path)
    request = double(
      :request,
      host: 'test.com', protocol: 'http', path_parameters: {},
      engine_script_name: nil, original_script_name: nil
    ).as_null_object

    controller_instance = ApplicationController.new
    controller_instance.set_request!(request)

    view = controller_instance.view_context
    allow(view).to receive(:current_application).and_return(current_application)
    view.instance_variable_set(:@virtual_path, virtual_path)

    view
  end
end

RSpec.configuration.include ViewContext
