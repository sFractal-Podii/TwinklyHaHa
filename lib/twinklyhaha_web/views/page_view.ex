defmodule TwinklyhahaWeb.PageView do
  use TwinklyhahaWeb, :view
  import Phoenix.Component

  def render("sbom.html", assigns) do
    files =
      :twinklyhaha
      |> Application.app_dir("/priv/static/.well-known/sbom")
      |> File.ls!()

    sbom_files =
      Enum.reduce(["cyclonedx", "spdx", "vex"], %{}, fn filter, acc ->
        Map.put(acc, filter, filter_files(files, filter))
      end)

    ~H"""
    <p>SBOMs for this site are available in several formats and serializations. </p>
    <%= for {bom_name, bom_file} <- sbom_files do %>
      <ol> <%= bom_name %> </ol>
      <%= for file <- bom_file do %>
          <li> <%= link file,  to: ["sbom/",file] %> </li>
      <% end %>
    <% end %>
    """
  end

  defp filter_files(files, filter) do
    regex = Regex.compile!(filter)
    files |> Enum.filter(fn file -> Regex.match?(regex, file) end)
  end
end
