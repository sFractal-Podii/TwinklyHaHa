defmodule TwinklyhahaWeb.OC2Controller do
  require Logger
  use TwinklyhahaWeb, :controller
  alias Openc2.Oc2.Command

  @topic "leds"

  def command(conn, params) do
    params
    |> Jason.encode!()
    |> Openc2.Oc2.Command.new()
    |> Openc2.Oc2.Command.do_cmd()
    |> handle_response(conn)
  end

  defp handle_response(%Openc2.Oc2.Command{target: nil}, conn) do
    send_resp(conn, :unprocessable_entity, "Oops! no target?")
  end

  defp handle_response(%Openc2.Oc2.Command{target: command}, conn) do
    Phoenix.PubSub.broadcast(Twinklyhaha.PubSub, @topic, command)
    json(conn, %{status: :ok})
  end
end
