defmodule Player do
  def loop(stack) do
    IO.puts "#{inspect self}: My stack is #{inspect stack}"
    receive do
      { dealer, :card } when length(stack) == 0 ->
        IO.puts "#{inspect self}: I got no more cards!"
        send dealer, { self, :card, [] }

        loop(stack)
      { dealer, :card } ->
        [ head | stack ] = stack
        send dealer, { self, :card, head }

        loop(stack)
      { dealer, :cards } when length(stack) == 0 ->
        IO.puts "#{inspect self}: I got no more cards!"
        send dealer, { self, :cards, [] }

        loop(stack)
      { dealer, :cards } when length(stack) < 3 ->
        IO.puts "#{inspect self}: Was told to play 3 cards, but can't!"
        cards = Enum.take stack, 3
        stack = stack -- cards
        send dealer, { self, :cards, cards }

        loop(stack)
      { dealer, :cards } ->
        IO.puts "#{inspect self}: Was told to play 3 cards"
        [ a, b, c | stack ] = stack
        send dealer, { self, :cards, [ a, b, c ] }

        loop(stack)
      { _dealer, :victory, cards } ->
        IO.puts "#{inspect self}: Won these cards: #{inspect cards}"

        loop(stack ++ cards)
      :game_over -> IO.puts "#{inspect self}: Exiting game"
      _ -> IO.puts "Whatever"
    end
  end
end
