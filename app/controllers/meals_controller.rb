
class MealsController < ApplicationController
  def display_form
    render({ :template => "meal_templates/blank_form" })
  end

  def send_to_ai
    @the_description = params.fetch("description_param")

    render({ :template => "meal_templates/results" })
  end
end
