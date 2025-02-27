defmodule ShaderBackend.LLMClient do
  def generate_shader(description) do
    api_key = OPENAI_API_KEY 
    url = "https://api.openai.com/v1/chat/completions"
    headers = [
      {"Authorization", "Bearer #{api_key}"},
      {"Content-Type", "application/json"}
    ]
    body = Jason.encode!(%{
      model: "gpt-3.5-turbo",
      messages: [
        %{
          "role" => "user",
          "content" => "Generate a simple GLSL fragment shader code (no explanations) for: #{description}. Start with 'precision mediump float;'"
        }
      ],
      max_tokens: 500
    })

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: resp}} ->
        data = Jason.decode!(resp)
        data["choices"][0]["message"]["content"]
      {:ok, %HTTPoison.Response{status_code: code, body: resp}} ->
        IO.puts("ChatGPT failed with status #{code}: #{resp}")
        mock_shader(description)
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("ChatGPT error: #{inspect(reason)}")
        mock_shader(description)
    end
  end

  defp mock_shader(description) do
    desc = String.downcase(description)
    cond do
      String.contains?(desc, "gradient") ->
        """
        precision mediump float;
        void main() {
          vec2 uv = gl_FragCoord.xy / 400.0;
          gl_FragColor = vec4(uv.x, uv.y, 0.5, 1.0);
        }
        """
      String.contains?(desc, "blue") ->
        """
        precision mediump float;
        void main() {
          gl_FragColor = vec4(0.0, 0.0, 1.0, 1.0);
        }
        """
      true ->
        """
        precision mediump float;
        void main() {
          gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
        }
        """
    end
  end
end