defmodule TwinklyhahaWeb.OC2Controller do
  require Logger
  use TwinklyhahaWeb, :controller

  @topic "leds"
  @on "on"
  @off "off"

  def command(conn, params) do
    command =
      params
      |> Jason.encode!()
      |> Openc2.Oc2.Command.new()
      |> Openc2.Oc2.Command.do_cmd()
    case command.target do
      nil ->
        send_resp(conn, :unprocessable_entity, "Oops! no target?")

      _ ->
        Phoenix.PubSub.broadcast(Twinklyhaha.PubSub, @topic, command.target_specifier)
        json(conn, %{status: :ok})
    end
    #sbom command -> {"action": "query",
    #  "target": {"sbom": {"type": ["cyclonedx"]}}
    #    }
    # Add openc2 library
    # call command.new
    # call command.doc_cmd
    # if do.cmd returns an error  send_resp(conn, :unprocessable_entity, "Oops! bad target")
    # if successful use target specifier to publish the command
    # =======================================
  end
end
