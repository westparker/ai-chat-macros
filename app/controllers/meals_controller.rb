
class MealsController < ApplicationController
  def display_form
    render({ :template => "meal_templates/blank_form" })
  end

 def send_to_ai
  @the_description = params.fetch("description_param", "")

  @uploaded_photo = params.fetch("photo_param", "")

  if @uploaded_photo.present?
    @photo_data_uri = DataURI.convert(@uploaded_photo)
  end

   @chat = AI::Chat.new

  @chat.system("You are an expert nutritionist. The user will provide a photo and/or a description of a meal. Estimate the number of carbs (g), fat (g), protein (g), and calories (kcal) in the meal.")

if @uploaded_photo.present?
    @chat.user(@the_description, :image => @uploaded_photo)
  else
    @chat.user(@the_description)
  end

  @chat.schema_file = "lib/openai_schemas/meal_schema.json"
  @api_response = @chat.generate!
  @ai_content = @api_response.fetch(:content)

  render({:template => "meal_templates/results" })
end
