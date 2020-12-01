defmodule Droniverse.Generators.Universe do
  @enforce_keys ~w[config next_number]a
  defstruct config: nil,
            next_number: nil,
            expansion_sectors: :queue.new(),
            sectors: Map.new(),
            used_coordinates: Map.new()

  alias Droniverse.{Generators, Universe, Sector}

  def generate(config \\ []) do
    config
    |> seed_big_bang_from_config()
    |> generate_starting_sector
    |> expand_sectors
    |> to_universe()
  end

  defp seed_big_bang_from_config(config) do
    config = Generators.Config.new(config)
    %__MODULE__{config: config, next_number: config.starting_number}
  end

  defp generate_starting_sector(big_bang) do
    add_sector(big_bang, coordinates: big_bang.config.starting_coordinates)
  end

  defp add_sector(big_bang, sector_fields) do
    sector =
      Generators.Sector.generate(
        big_bang.config,
        Keyword.put(sector_fields, :number, big_bang.next_number)
      )

    sectors =
      Enum.reduce(
        sector.connections,
        Map.put(big_bang.sectors, sector.number, sector),
        fn connection, sectors ->
          connect_sectors(sectors, sector.number, connection)
        end
      )

    %__MODULE__{
      big_bang
      | next_number: big_bang.next_number + 1,
        expansion_sectors: :queue.in(sector, big_bang.expansion_sectors),
        sectors: sectors,
        used_coordinates:
          Map.put(
            big_bang.used_coordinates,
            sector.coordinates,
            sector.number
          )
    }
  end

  defp connect_sectors(sectors, number, connection) do
    Map.update!(sectors, connection, fn connected_sector ->
      %Sector{
        connected_sector
        | connections: Enum.uniq(connected_sector.connections ++ [number])
      }
    end)
  end

  defp expand_sectors(big_bang) do
    case find_next_expansion_sector(big_bang) do
      {sector, big_bang} ->
        big_bang
        |> generate_connections(sector)
        |> expand_sectors

      nil ->
        if map_size(big_bang.sectors) >= big_bang.config.sector_count do
          big_bang
        else
          big_bang
          |> find_new_expansion_point
          |> expand_sectors
        end
    end
  end

  defp find_next_expansion_sector(big_bang) do
    case :queue.out(big_bang.expansion_sectors) do
      {{:value, sector}, expansion_sectors} ->
        {sector, %__MODULE__{big_bang | expansion_sectors: expansion_sectors}}

      {:empty, _expansion_sectors} ->
        nil
    end
  end

  defp generate_connections(big_bang, sector) do
    {x, y} = sector.coordinates

    count =
      Enum.min([
        calculate_connection_count(big_bang, sector),
        big_bang.config.sector_count - map_size(big_bang.sectors)
      ])

    if rem(y, 2) == 0 do
      [{0, -1}, {1, 0}, {0, 1}, {-1, 1}, {-1, 0}, {-1, -1}]
    else
      [{1, -1}, {1, 0}, {1, 1}, {0, 1}, {-1, 0}, {0, -1}]
    end
    |> Enum.map(fn {x_offset, y_offset} -> {x + x_offset, y + y_offset} end)
    |> Enum.filter(fn {x, y} ->
      x >= big_bang.config.min_x_coordinate and
        x <= big_bang.config.max_x_coordinate and
        y >= big_bang.config.min_y_coordinate and
        y <= big_bang.config.max_y_coordinate
    end)
    |> Enum.shuffle()
    |> Enum.take(count)
    |> Enum.reduce(big_bang, fn coordinates, big_bang ->
      big_bang.sectors
      |> Map.get(Map.get(big_bang.used_coordinates, coordinates))
      |> case do
        %Sector{} = existing_sector ->
          if length(existing_sector.connections) < 6 do
            sectors =
              big_bang.sectors
              |> connect_sectors(sector.number, existing_sector.number)
              |> connect_sectors(existing_sector.number, sector.number)

            %__MODULE__{big_bang | sectors: sectors}
          else
            big_bang
          end

        nil ->
          add_sector(
            big_bang,
            coordinates: coordinates,
            connections: [sector.number]
          )
      end
    end)
  end

  defp calculate_connection_count(
         %__MODULE__{config: %Generators.Config{starting_number: number}},
         %Sector{number: number}
       ) do
    6
  end

  defp calculate_connection_count(big_bang, sector) do
    weighted_connections_table =
      if sector.number <= big_bang.config.sector_count * 0.10 do
        %{5 => 22.5, 4 => 33, 3 => 22.5, 2 => 10, 1 => 7, 0 => 5}
      else
        %{5 => 5, 4 => 7, 3 => 10, 2 => 22.5, 1 => 33, 0 => 22.5}
      end

    selection = :rand.uniform(100)

    Enum.reduce_while(weighted_connections_table, 0, fn {count, percent}, sum ->
      sum = sum + percent

      if selection <= sum do
        {:halt, count}
      else
        {:cont, sum}
      end
    end)
  end

  defp find_new_expansion_point(big_bang) do
    {starting_x, starting_y} = big_bang.config.starting_coordinates

    sector =
      big_bang.sectors
      |> Map.values()
      |> Enum.min_by(fn sector ->
        {x, y} = sector.coordinates

        [
          length(sector.connections),
          abs(starting_x - x) + abs(starting_y - y),
          sector.number
        ]
      end)

    %__MODULE__{
      big_bang
      | expansion_sectors: :queue.in(sector, big_bang.expansion_sectors)
    }
  end

  defp to_universe(big_bang) do
    coordinate_index =
      big_bang.used_coordinates
      |> Enum.filter(fn {_coordinates, contents} -> is_integer(contents) end)
      |> Map.new()

    {min_x, max_x} =
      big_bang.sectors
      |> Enum.map(fn {_number, sector} -> elem(sector.coordinates, 0) end)
      |> Enum.min_max()

    {min_y, max_y} =
      big_bang.sectors
      |> Enum.map(fn {_number, sector} -> elem(sector.coordinates, 1) end)
      |> Enum.min_max()

    Universe.new(
      sectors: big_bang.sectors,
      coordinate_index: coordinate_index,
      min_x: min_x,
      max_x: max_x,
      x_range: max_x - min_x + 1,
      min_y: min_y,
      max_y: max_y,
      y_range: max_y - min_y + 1
    )
  end
end
