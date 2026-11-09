require "rails_helper"
require "support/ai_chat_stubs"

describe "/approximate" do
  it "has a functional page", points: 1 do
    visit "/approximate"

    expect(page.status_code).to be(200)
  end
end

describe "/approximate" do
  it "has a textarea with the name \"description_param\"", points: 1, hint: h("names_for_inputs") do
    visit "/approximate"

    expect(page).to have_css("textarea[name='description_param']"),
      "Expected to find a <textarea> with name=\"description_param\", but didn't."
  end
end

describe "/approximate" do
  it "has a file upload input with the name \"photo_param\"", points: 1, hint: h("file_input names_for_inputs") do
    visit "/approximate"

    expect(page).to have_css("input[type='file'][name='photo_param']"),
      "Expected to find an <input type=\"file\"> with name=\"photo_param\", but didn't."
  end
end

describe "/approximate" do
  it "has a form that POSTs to /process_inputs with multipart encoding", points: 1, hint: h("multipart_form") do
    visit "/approximate"

    form = find("form")
    actual = { action: form[:action], method: form[:method], enctype: form[:enctype] }

    expect(actual).to eq({ action: "/process_inputs", method: "post", enctype: "multipart/form-data" }),
      "Expected the form to have action=\"/process_inputs\", method=\"post\", and enctype=\"multipart/form-data\", but its attributes were #{actual.inspect}."
  end
end

describe "/process_inputs" do
  it "leads to a functional results page when a description is submitted", points: 1, hint: h("multipart_form canned_grader") do
    visit "/approximate"

    fill_in "description_param", with: "A bowl of spaghetti with two meatballs"

    find("button").click

    expect(page.status_code).to be(200)
  end
end

describe "/process_inputs" do
  it "displays the grams of carbohydrates from the AI's response", points: 1, hint: h("canned_grader") do
    visit "/approximate"

    fill_in "description_param", with: "A bowl of spaghetti with two meatballs"

    find("button").click

    expect(page).to have_content(47),
      "Expected the results page to display the 47 g of carbs from the canned grading response, but didn't find the number 47 anywhere on the page."
  end
end

describe "/process_inputs" do
  it "displays the grams of fat from the AI's response", points: 1, hint: h("canned_grader") do
    visit "/approximate"

    fill_in "description_param", with: "A bowl of spaghetti with two meatballs"

    find("button").click

    expect(page).to have_content(23),
      "Expected the results page to display the 23 g of fat from the canned grading response, but didn't find the number 23 anywhere on the page."
  end
end

describe "/process_inputs" do
  it "displays the grams of protein from the AI's response", points: 1, hint: h("canned_grader") do
    visit "/approximate"

    fill_in "description_param", with: "A bowl of spaghetti with two meatballs"

    find("button").click

    expect(page).to have_content(31),
      "Expected the results page to display the 31 g of protein from the canned grading response, but didn't find the number 31 anywhere on the page."
  end
end

describe "/process_inputs" do
  it "displays the total calories from the AI's response", points: 1, hint: h("canned_grader") do
    visit "/approximate"

    fill_in "description_param", with: "A bowl of spaghetti with two meatballs"

    find("button").click

    expect(page).to have_content(519),
      "Expected the results page to display the 519 kcal total from the canned grading response, but didn't find the number 519 anywhere on the page."
  end
end

describe "/process_inputs" do
  it "displays an uploaded photo using a data URI", points: 1, hint: h("data_uri") do
    visit "/approximate"

    attach_file "photo_param", Rails.root.join("spec/fixtures/meal_photo.png")

    find("button").click

    expect(page).to have_css("img[src^='data:']"),
      "Expected the results page to display the uploaded photo in an <img> tag whose src is a data URI (starting with \"data:\"), but didn't find one."
  end
end
