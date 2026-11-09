
Rails.application.routes.draw do
  get("/approximate", { :controller => "meals", :action => "display_form" })

  get("/", { :controller => "meals", :action => "display_form" })

  get("/process_inputs", { :controller => "meals", :action => "send_to_ai" })
end
