defmodule TwinklyhahaWeb.PageView do
  use TwinklyhahaWeb, :view

  def render("sbom.html", assigns) do
    ~H"""
    <p>SBOMs for this site are available in several formats and serializations. </p>
    <%= for {k, v} <- sbom_files() do %>
      <ol> <%= k %> </ol>
      <%= for file <- v do %>
          <li> <%= link file,  to: ["sbom/",file] %> </li>
      <% end %>
    <% end %>
    """
  end

  defp filter_files(files, filter) do
    regex = Regex.compile!(filter)
    files |> Enum.filter(fn file -> Regex.match?(regex, file) end)
  end

  defp sbom_files do
    files =
      :twinklyhaha
      |> Application.app_dir("/priv/static/.well-known/sbom")
      |> File.ls!()

      Enum.reduce(["cyclonedx", "spdx", "vex"], %{}, fn filter, acc ->
        Map.put(acc, filter, filter_files(files, filter))
      end)
  end
end
