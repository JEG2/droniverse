defmodule Droniverse.Generators.Sector do
  alias Droniverse.Sector

  def generate(_config \\ [], fields) do
    Sector.new(fields)
  end
end
