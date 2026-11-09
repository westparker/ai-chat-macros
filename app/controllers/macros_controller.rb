class MacrosController < ApplicationController
  def display_form
    render({ :template => "macros/form" })
  end

  def send_to_ai
    @the_description = params.fetch("description_param")

    render({ :template => "macros_templates/results" })
  end
end
