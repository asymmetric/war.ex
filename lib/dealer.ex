defmodule Dealer do
  @suits 'CH'
  @ranks '23456789'
  @count 8

  def start do
    import Enum

    cards = for suit <- @suits, rank <- @ranks, do: [ suit, rank ]

    cards =
      cards
      |> shuffle
      |> take(@count)
      |> split(div(@count, 2))

    one = spawn(Player, :loop, [ elem(cards, 0) ])
    two = spawn(Player, :loop, [ elem(cards, 1) ])

    loop(%{}, one, two)
  end

  defp loop(%{}, player_one, player_two) do
    IO.puts "Empty stack, we're in a battle"
    send player_one, { self, :card }
    send player_two, { self, :card }
    cards = receive_cards(player_one, player_two)

    case compare(cards) do
      { :winner, :one } ->
        IO.puts "#{inspect player_one} won the battle!"
        send player_one, { self, :victory, Tuple.to_list cards }

        loop(%{}, player_one, player_two)
      { :winner, :two } ->
        IO.puts "#{inspect player_two} won the battle!"
        send player_two, { self, :victory, Tuple.to_list cards }

        loop(%{}, player_one, player_two)
      { :war, cards } ->
        IO.puts "We have a war!"
        loop(cards, player_one, player_two)
    end
  end

  defp loop(pile, player_one, player_two) do
    IO.puts "The pile is #{pile}"
    send player_one, { self, :cards }
    send player_two, { self, :cards }

    cards = receive_cards(player_one, player_two)

    case compare_multiple(cards) do
      { :winner, :one } ->
        IO.puts "#{inspect player_one} won the war!"
        { cards_one, cards_two } = cards
        send player_one, { self, :victory, cards_one ++ cards_two }

        loop(%{}, player_one, player_two)
      { :winner, :two } ->
        IO.puts "#{inspect player_two} won the war!"
        { cards_one, cards_two } = cards
        send player_two, { self, :victory, cards_one ++ cards_two }

        loop(%{}, player_one, player_two)
      { :war, cards } ->
        IO.puts "The war goes on!!"
        loop(cards, player_one, player_two)
      { :king, :one } ->
        IO.puts "#{inspect player_one} wins!!"
        System.halt 0
      { :king, :two } ->
        IO.puts "#{inspect player_two} wins!!"
        System.halt 0
    end
  end

  defp receive_cards(player_one, player_two, play_count \\ 0, pile_one \\ Map.new, pile_two \\ Map.new)

  # second card received
  defp receive_cards(player_one, player_two, 1, pile_one, pile_two) do
    receive do
      { pid, :card, card } ->
        IO.puts "Player #{inspect pid} played #{card}"
        cond do
          pid == player_one -> { card, pile_two }
          pid == player_two -> { pile_one, card }
        end
      { pid, :cards, cards } ->
        IO.puts "Player #{inspect pid} played #{cards}"
    end
  end

  # first card received
  defp receive_cards(player_one, player_two, play_count, pile_one, pile_two) do
    receive do
      { pid, :card, card } ->
        IO.puts "Player #{inspect pid} played #{card}"
        cond do
          pid == player_one ->
            receive_cards(player_one, player_two, play_count + 1, card, pile_two)
          pid == player_two ->
            receive_cards(player_one, player_two, play_count + 1, pile_one, card)
        end
      { pid, :cards, cards } ->
        IO.puts "Player #{inspect pid} played #{cards}"
    end

  end

  def compare({[], _}), do: { :king, :two }
  def compare({_, []}), do: { :king, :one }
  def compare_multiple({a, b}) do
    {[ head_a | a ], [ head_b | b ]} =  { a, b }
    compare({ head_a, head_b })
  end

  def compare({ a, b }) do
    {[ _ | rank_a ], [ _ | rank_b ]} = { a, b }

    case _compare(rank_a, rank_b) do
      { :war } -> { :war, [ a, b ] }
      retval -> retval
    end
  end

  defp _compare(a, b) when a > b, do: { :winner, :one }
  defp _compare(a, b) when a < b, do: { :winner, :two }
  defp _compare(a, a), do: { :war }
end
