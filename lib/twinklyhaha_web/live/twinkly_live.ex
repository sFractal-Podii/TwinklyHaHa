defmodule TwinklyhahaWeb.TwinklyLive do
  @moduledoc "Live view for the LED"

  use TwinklyhahaWeb, :live_view

  require Logger

  @colors ["Violet", "Indigo", "Blue", "Green", "Yellow", "Orange", "Red"]

  @topic "leds"

  @impl true
  def mount(_params, _session, socket) do
    ## subscribe to pubsub topic
    TwinklyhahaWeb.Endpoint.subscribe(@topic)
    {:ok, assign(socket, led_on?: false, current_color: hd(@colors), colors: @colors)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="row">
    <div class="column column-50 column-offset-25">
        <%= for row <- 0..7 do %>
          <%= for column <- 0..7 do %>
            <div class="led-box">
            <div class={["led", "led-#{if @led_on?, do: "on", else: "off"}"]} id={"led-#{row}#{column}"} 
                data-ledcolor={if @current_color == "rainbow", do: Stream.cycle(@colors) |> Enum.at(row), else: @current_color} phx-hook="LedColor"></div>
            </div>
          <% end %>
           <br />
        <% end %>
        <%= if @led_on?, do: select_color(assigns) %>
        <div>
          <a class="button" phx-click="toggle-led">Turn LED <%= if @led_on?, do: "OFF", else: "ON" %> </a>
        </div>
      </div>
    </div>
    """
  end

  defp select_color(assigns) do
    ~H"""
    <form phx-change="change-color">
      <select id="select-colors" name="color">
      <%= for color <- @colors do %>
          <option value={color} selected={if @current_color == color, do: "selected"}  >
            <%= color %>
          </option>
        <% end %>
      <option value={"rainbow"} selected={if @current_color == "rainbow", do: "selected" }>
        Rainbow
      </option>
    </select>
    </form>
    """
  end

  @impl true
  def handle_event("toggle-led", _, socket) do
    socket = assign(socket, :led_on?, !socket.assigns.led_on?)
    color = hd(socket.assigns.colors)
    {:noreply, current_color(socket, color, socket.assigns.led_on?)}
  end

  @impl true
  def handle_event("change-color", %{"color" => color}, socket) do
    {:noreply, current_color(socket, color, socket.assigns.led_on?)}
  end

  @impl true
  def handle_info(:shift_color, socket) do
    case socket.assigns.current_color do
      "rainbow" ->
        Process.send_after(self(), :shift_color, 100)
        {:noreply, shift_colors(socket)}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_info("on", socket) do
    Logger.debug("tlive:hand.info - on")
    {:noreply, current_color(socket, hd(@colors), true)}
  end

  def handle_info("off", socket) do
    Logger.debug("tlive:hand.info- off")
    {:noreply, assign(socket, :current_color, "rgba(0, 0, 0, 0.2)")}
  end

  def handle_info(color, socket)
      when color == "rainbow" or color == "red" or color == "orange" or color == "yellow" or
             color == "green" or
             color == "blue" or color == "indigo" or color == "violet" do
    Logger.debug("tlive:hand.info - #{color}")
    {:noreply, current_color(socket, color, true)}
  end

  def handle_info(what_wrong, socket) do
    Logger.debug("tlive:hand.info- wrong - #{inspect(what_wrong)}")
    {:noreply, assign(socket, :current_color, "rgba(0, 0, 0, 0.2)")}
  end

  defp shift_colors(socket) do
    [hd | tail] = socket.assigns.colors
    assign(socket, :colors, tail ++ [hd])
  end

  defp current_color(socket, "rainbow", true) do
    Process.send_after(self(), :shift_color, 100)
    assign(socket, :current_color, "rainbow")
  end

  defp current_color(socket, _color, _led_on? = false) do
    assign(socket, :current_color, "rgba(0, 0, 0, 0.2)")
  end

  defp current_color(socket, color, _led_on? = true) do
    assign(socket, :current_color, color)
  end
end
