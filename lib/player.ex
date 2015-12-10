defmodule Player do
  def loop(stack) do
    IO.puts "#{inspect self}: My stack is #{inspect stack}"
    receive do
      { dealer, :card } ->
        [ head | stack ] = stack
        send dealer, { self, :card, head }
        loop(stack)
      { dealer, :cards } ->
        IO.puts "Was told to play 3 cards"
        [ a, b, c | stack ] = stack
        send dealer, { self, :cards, [ a, b, c ] }
      { dealer, :victory, cards } ->
        IO.puts "#{inspect self}: Won these cards: #{inspect cards}"
        loop(stack ++ cards)
      _ -> IO.puts "Whatever"
    end
  end
end
