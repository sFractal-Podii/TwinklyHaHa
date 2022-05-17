defmodule TwinklyhahaWeb.PageController do
  use TwinklyhahaWeb, :controller

  def sbom(conn, _params) do
    render(conn, "sbom.html")
  end

  end
