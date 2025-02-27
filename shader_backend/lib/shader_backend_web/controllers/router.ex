defmodule ShaderBackendWeb.Router do
  use Plug.Router
  plug CORSPlug, origin: ["http://localhost:3000"]
  plug :match
  plug :dispatch

  post "/api/shader" do
    {:ok, body, conn} = Plug.Conn.read_body(conn)
    %{"description" => desc} = Jason.decode!(body)
    shader_code = ShaderBackend.LLMClient.generate_shader(desc)
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{shader: shader_code}))
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end