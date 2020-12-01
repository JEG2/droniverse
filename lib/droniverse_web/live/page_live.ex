defmodule DroniverseWeb.PageLive do
  use DroniverseWeb, :live_view
  alias Droniverse.{Universe, Sector}

  @impl true
  def mount(_params, _session, socket) do
    state = Droniverse.Map.init()
    {:ok, assign(socket, state)}
  end

  @impl true
  def handle_event("record_drawing_sizes", sizes, socket) do
    changes = Droniverse.Map.record_drawing_sizes(socket.assigns, sizes)
    {:noreply, assign(socket, changes)}
  end

  @impl true
  def handle_event("react_to_key_down", %{"key" => "Shift"}, socket) do
    changes = Droniverse.Map.record_shift_down(socket.assigns)
    {:noreply, assign(socket, changes)}
  end

  @impl true
  def handle_event("react_to_key_down", _key, socket), do: {:noreply, socket}

  @impl true
  def handle_event("react_to_key_up", %{"key" => "Shift"}, socket) do
    changes = Droniverse.Map.record_shift_up(socket.assigns)
    {:noreply, assign(socket, changes)}
  end

  @impl true
  def handle_event("react_to_key_up", %{"key" => "ArrowUp"}, socket) do
    changes = Droniverse.Map.scroll_up(socket.assigns)
    {:noreply, assign(socket, changes)}
  end

  @impl true
  def handle_event("react_to_key_up", %{"key" => "ArrowDown"}, socket) do
    changes = Droniverse.Map.scroll_down(socket.assigns)
    {:noreply, assign(socket, changes)}
  end

  @impl true
  def handle_event("react_to_key_up", %{"key" => "ArrowLeft"}, socket) do
    changes = Droniverse.Map.scroll_left(socket.assigns)
    {:noreply, assign(socket, changes)}
  end

  @impl true
  def handle_event("react_to_key_up", %{"key" => "ArrowRight"}, socket) do
    changes = Droniverse.Map.scroll_right(socket.assigns)
    {:noreply, assign(socket, changes)}
  end

  @impl true
  def handle_event("react_to_key_up", _key, socket), do: {:noreply, socket}

  defp to_data(%Universe{} = universe) do
    universe
    |> Map.from_struct()
    |> Map.delete(:coordinate_index)
    |> Map.put(
      :sectors,
      Enum.into(universe.sectors, Map.new(), fn {number, sector} ->
        {to_string(number), to_data(sector)}
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
