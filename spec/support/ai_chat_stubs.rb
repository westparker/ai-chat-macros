# Intercept all requests to the OpenAI API (whether direct or through the
# Prepend.me proxy) so that `rails grade` never makes a real API call and never
# spends anyone's credits. Instead of a real model, the grader replies with a
# canned nutrition estimate:
#
#   carbs: 47 g, fat: 23 g, protein: 31 g, total calories: 519 kcal
#
# If the app sends a JSON Schema (structured output), the canned reply is built
# to match that schema, whatever the exact key names are.

require "webmock/rspec"

WebMock.disable_net_connect!(allow_localhost: true)

# Make sure AI::Chat can initialize even if no .env file is present. (The
# stubs below accept any key, real or not.)
ENV["AICHAT_PROXY"] ||= "true"
ENV["AICHAT_PROXY_KEY"] ||= "canned-grading-key"
ENV["OPENAI_API_KEY"] ||= "canned-grading-key"

module AiChatStubs
  OPENAI_HOSTS = %r{https://(prepend\.me/api\.openai\.com|api\.openai\.com)}

  CANNED_NUMBERS = {
    /carb/i => 47,
    /fat/i => 23,
    /protein/i => 31,
    /calorie|kcal|energy/i => 519
  }.freeze

  CANNED_RATIONALE = "This is a canned response from the automated grader " \
    "(no real API call was made): a meal estimated at 47 g carbs, 23 g fat, " \
    "31 g protein, and 519 kcal total."

  CANNED_PLAIN_TEXT = "Estimated nutrition for the meal: approximately " \
    "47 g of carbohydrates, 23 g of fat, and 31 g of protein, for a total " \
    "of about 519 kcal.\n\n(This is a canned response from the automated " \
    "grader; no real API call was made.)"

  # Build a value that satisfies one node of a JSON Schema, picking canned
  # numbers/strings based on the key name.
  def self.value_for(key, schema)
    case schema["type"]
    when "object"
      schema.fetch("properties", {}).map { |k, v| [k, value_for(k, v)] }.to_h
    when "array"
      [value_for(key, schema.fetch("items", { "type" => "string" }))]
    when "integer", "number"
      pair = CANNED_NUMBERS.find { |pattern, _| key.to_s.match?(pattern) }
      pair ? pair.last : 42
    when "string"
      if key.to_s.match?(/rationale|explanation|reason|note/i)
        CANNED_RATIONALE
      else
        "Canned grading value for '#{key}'"
      end
    when "boolean"
      true
    end
  end

  # The text the "model" replies with: JSON matching the app's schema if one
  # was sent along with the request, plain prose otherwise.
  def self.output_text_for(request_body)
    parsed = JSON.parse(request_body)
    format = parsed.dig("text", "format")

    if format.is_a?(Hash) && format["schema"].is_a?(Hash)
      JSON.generate(value_for("response", format.fetch("schema")))
    else
      CANNED_PLAIN_TEXT
    end
  rescue JSON::ParserError
    CANNED_PLAIN_TEXT
  end

  def self.response_body_for(request_body)
    JSON.generate(
      {
        id: "resp_canned_grading",
        object: "response",
        created_at: 0,
        status: "completed",
        model: "canned-grading-model",
        conversation: { id: "conv_canned_grading" },
        output: [
          {
            type: "message",
            id: "msg_canned_grading",
            status: "completed",
            role: "assistant",
            content: [
              {
                type: "output_text",
                text: output_text_for(request_body),
                annotations: []
              }
            ]
          }
        ],
        usage: { input_tokens: 1, output_tokens: 1, total_tokens: 2 }
      }
    )
  end
end

RSpec.configure do |config|
  config.before(:each) do
    json_headers = { "Content-Type" => "application/json" }

    # AI::Chat validates the API key with a harmless "list the models" call.
    stub_request(:get, %r{#{AiChatStubs::OPENAI_HOSTS}/v1/models}).
      to_return(
        status: 200,
        headers: json_headers,
        body: JSON.generate(
          {
            object: "list",
            data: [{ id: "canned-grading-model", object: "model", created: 0, owned_by: "openai" }]
          }
        )
      )

    # AI::Chat creates a conversation before its first response.
    stub_request(:post, %r{#{AiChatStubs::OPENAI_HOSTS}/v1/conversations}).
      to_return(
        status: 200,
        headers: json_headers,
        body: JSON.generate(
          { id: "conv_canned_grading", object: "conversation", created_at: 0, metadata: {} }
        )
      )

    # The main event: the model's reply.
    stub_request(:post, %r{#{AiChatStubs::OPENAI_HOSTS}/v1/responses}).
      to_return do |request|
        {
          status: 200,
          headers: json_headers,
          body: AiChatStubs.response_body_for(request.body)
        }
      end
  end
end
