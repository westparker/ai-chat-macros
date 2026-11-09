def send_to_ai
  @the_description = params.fetch("description_param")

  render({:template => "meal_templates/results" })
end
