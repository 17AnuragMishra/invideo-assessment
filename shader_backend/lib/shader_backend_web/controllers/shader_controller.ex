defmodule ShaderBackendWeb.ShaderController do
  use ShaderBackendWeb, :controller
  require Logger

  def generate(conn, %{"description" => description}) do
    prompt = """
    Generate a WebGL shader for the following request: "#{description}". 
    - Provide a complete vertex and fragment shader. 
    - The vertex shader should handle 3D transformations for a rotating cube.
    - The fragment shader should include a gradient background.
    - Ensure the shader is valid GLSL and follows WebGL standards.
    - Output should be formatted as:
      ```
      Vertex Shader:
      <vertex shader code>
      Fragment Shader:
      <fragment shader code>
      ```
    """

    case call_llm(prompt) do
      {:ok, response} ->
        Logger.info("Shader generated successfully.")
        shader_code = extract_shader_code(response)
        json(conn, %{shader: shader_code})

      {:error, reason} ->
        Logger.error("LLM request failed: #{reason}")
        json(conn, %{error: "Failed to generate shader"})
    end
  end

  defp call_llm(prompt) do
    # Modify this function to send a request to GPT/Grok/Gemini API.
    HTTPoison.post(
      "https://api.your-llm-provider.com",
      Jason.encode!(%{prompt: prompt, max_tokens: 512}),
      [{"Content-Type", "application/json"}]
    )
    |> handle_llm_response()
  end

  defp handle_llm_response({:ok, %HTTPoison.Response{body: body}}) do
    {:ok, Jason.decode!(body)["choices"] |> List.first() |> Map.get("text")}
  end
  defp handle_llm_response(_), do: {:error, "LLM API request failed"}

  defp extract_shader_code(response) do
    # Extract GLSL code from LLM response (basic string processing)
    response
    |> String.split("Fragment Shader:", parts: 2)
    |> case do
      [vertex, fragment] -> %{vertex: String.trim(vertex), fragment: String.trim(fragment)}
      _ -> %{error: "Invalid shader format"}
    end
  end
end
