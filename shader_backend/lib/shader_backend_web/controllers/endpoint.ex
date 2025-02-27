defmodule ShaderBackendWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :shader_backend

  plug CORSPlug, origin: ["http://localhost:3000"]

  plug Plug.Static,
    at: "/",
    from: :shader_backend,
    gzip: false

  plug Plug.RequestId
  plug Plug.Logger
  plug Plug.Parsers, parsers: [:urlencoded, :multipart, :json],
                     pass: ["*/*"],
                     json_decoder: Phoenix.json_library()
  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, store: :cookie, key: "_shader_backend_key",
                     signing_salt: "some_salt"

  plug ShaderBackendWeb.Router
end
