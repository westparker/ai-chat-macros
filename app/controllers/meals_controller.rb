
class MealsController < ApplicationController
  def display_form
    render({ :template => "meal_templates/blank_form" })
  end

  def send_to_ai
    @the_description = params.fetch("description_param")

   @chat = AI::Chat.new

  @chat.system("You are an expert nutritionist. The user will provide a photo and/or a description of a meal. Estimate the number of carbs (g), fat (g), protein (g), and calories (kcal) in the meal.")

  @chat.user(@the_description)

  @api_response = @chat.generate!

  render({:template => "meal_templates/results" })
end
end
