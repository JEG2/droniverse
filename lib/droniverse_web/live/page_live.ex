defmodule DroniverseWeb.PageLive do
  use DroniverseWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    universe =
      Enum.map(0..99, fn y ->
        Enum.map(0..99, fn x ->
          to_string(x + y * 100)
        end)
      end)

    {:ok, assign(socket, universe: universe)}
  end

  # @impl true
  # def handle_event("suggest", %{"q" => query}, socket) do
  #   {:noreply, assign(socket, results: search(query), query: query)}
  # end
end
