defmodule Droniverse.Map do
  alias Droniverse.Generators

  def init do
    universe = Generators.Universe.generate()

    %{
      universe: universe,
      canvas_width: nil,
      canvas_height: nil,
      sector_size: nil,
      view_x: 0,
      view_y: 0,
      shift_down: false
    }
  end

  def record_drawing_sizes(state, %{
        "canvas_width" => canvas_width,
        "canvas_height" => canvas_height,
        "sector_size" => sector_size
      }) do
    max_scrolls = %{
      max_horizontal_scroll: div(canvas_width - 1, sector_size) - 1,
      max_vertical_scroll: div(canvas_height, sector_size) - 1
    }

    {centered_x, centered_y} =
      state
      |> Map.merge(max_scrolls)
      |> center_on_coordinates({0, 0})

    %{
      canvas_width: canvas_width,
      canvas_height: canvas_height,
      sector_size: sector_size,
      view_x: centered_x,
      view_y: centered_y
    }
    |> Map.merge(max_scrolls)
  end

  def record_shift_down(_state), do: %{shift_down: true}

  def record_shift_up(_state), do: %{shift_down: false}

  def scroll_up(state) do
    %{view_y: Enum.max([state.view_y - vertical_scroll_factor(state), 0])}
  end

  def scroll_down(state) do
    %{
      view_y:
        Enum.min([
          state.view_y + vertical_scroll_factor(state),
          state.universe.y_range - state.max_vertical_scroll
        ])
    }
  end

  def scroll_left(state) do
    %{view_x: Enum.max([state.view_x - horizontal_scroll_factor(state), 0])}
  end

  def scroll_right(state) do
    %{
      view_x:
        Enum.min([
          state.view_x + horizontal_scroll_factor(state),
          state.universe.x_range - state.max_horizontal_scroll
        ])
    }
  end

  defp horizontal_scroll_factor(%{
         shift_down: false,
         max_horizontal_scroll: max_horizontal_scroll
       }) do
    max_horizontal_scroll
  end

  defp horizontal_scroll_factor(%{shift_down: true}), do: 1

  defp vertical_scroll_factor(%{
         shift_down: false,
         max_vertical_scroll: max_vertical_scroll
       }) do
    max_vertical_scroll
  end

  defp vertical_scroll_factor(%{shift_down: true}), do: 1

  defp center_on_coordinates(state, {x, y}) do
    {
      -state.universe.min_x + x - (state.max_horizontal_scroll + 1) / 2,
      -state.universe.min_y + y - (state.max_vertical_scroll + 1) / 2
    }
  end
end
