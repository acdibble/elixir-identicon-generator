defmodule Identicon do
  @moduledoc """
  Documentation for Identicon.
  """

  @doc """
    This function generates the image based off of the given input, and saves a
    .png file with the same name as the input

  ## Examples

      iex> Identicon.main("ya boi")
      :ok

  """

  def main(input) do
    input
    |> hash_input()
    |> pick_color()
    |> build_grid()
    |> filter_odd_squares()
    |> build_pixel_map()
    |> draw_image()
    |> save_image(input)
  end

  defp hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list()

    %Identicon.Image{ hex: hex }
  end

  defp pick_color(%Identicon.Image{ hex: [r, g, b | _tail] } = image) do
    %Identicon.Image{ image | color: { r, g, b } }
  end

  defp build_grid(%Identicon.Image{ hex: hex } = image) do
    grid =
      hex
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.map(&mirror_row/1)
      |> List.flatten()
      |> Enum.with_index(0)

    %Identicon.Image{image| grid: grid}
  end

  defp mirror_row(row) do
    [a, b, _c] = row
    row ++ [b, a]
  end

  defp filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    new_grid = Enum.filter(grid, fn({ num, _i }) -> rem(num, 2) == 0 end)

    %Identicon.Image{image | grid: new_grid}
  end

  defp build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map(grid, fn({ _num, index }) ->
      x = rem(index, 5) * 50
      y = div(index, 5) * 50

      { { x, y }, { x + 50, y + 50} }
    end)

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  defp draw_image(%Identicon.Image{ color: color, pixel_map: pixel_map }) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each(pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end)

    :egd.render(image)
  end

  defp save_image(binary, filename) do
    File.write("#{filename}.png", binary)
  end
end
