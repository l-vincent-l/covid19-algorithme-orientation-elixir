defmodule Covid19QuestionnaireWeb.Plugs.Authenticate do
  @moduledoc """
  If the token sent by the client isn't legit, the request gets rejected.
  """

  import Plug.Conn
  use PlugAttack
  alias Covid19Questionnaire.Data.Token

  rule "authenticate", conn do
    conn
    |> get_req_header("x-token")
    |> hd
    |> Token.find()
    |> allow
  end

  def allow_action(conn, token, _opts) do
    assign(conn, :token, token)
  end

  def block_action(conn, _data, _opts) do
    conn
    |> put_status(403)
    |> halt()
  end
end
