defmodule DroniverseWeb.PageLive do
  use DroniverseWeb, :live_view
  alias Droniverse.{Generators, Universe, Sector}

  @impl true
  def mount(_params, _session, socket) do
    universe = Generators.Universe.generate()
    {:ok, assign(socket, universe: universe)}
  end

  # @impl true
  # def handle_event("suggest", %{"q" => query}, socket) do
  #   {:noreply, assign(socket, results: search(query), query: query)}
  # end

  defp to_data(%Universe{} = universe) do
    universe
    |> Map.from_struct()
    |> Map.delete(:coordinate_index)
    |> Map.put(
      :sectors,
      Enum.map(universe.sectors, fn {_number, sector} ->
        to_data(sector)
      end)
    )
    |> Jason.encode!()
  end

  defp to_data(%Sector{} = sector) do
    sector
    |> Map.from_struct()
    |> Map.put(:coordinates, Tuple.to_list(sector.coordinates))
  end
end
