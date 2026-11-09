Rails.application.routes.draw do
  # This is a blank app! Pick your first screen, build out the RCAV, and go from there. E.g.:
  # get("/your_first_screen", { :controller => "pages", :action => "first" })
  get("/approximate", { :controller => "meals", :action => "display_form" })

  get("/process_inputs", { :controller => "meals", :action => "send_to_ai" })
end
