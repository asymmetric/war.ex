defmodule PlayerTest do
  use ExUnit.Case
  doctest Player
  import Player

  @cards [ 'H3', 'C3', 'H8', 'H6' ]

  setup do
    pid = spawn(Player, :loop, [ @cards ])
    { :ok, [ pid: pid ]}
  end

  test "player sends first card when asked", %{pid: pid} do
    send(pid, { self, :card })

    receive do
      { pid, :card, card } -> assert card == 'H3'
    after
      1000 -> raise "Damn"
    end
  end

  test "player sends first 3 cards when asked", %{pid: pid} do
    send(pid, { self, :cards })

    receive do
      { pid, :cards, cards } -> assert cards == [ 'H3', 'C3', 'H8' ]
    after
      1000 -> raise "Damn"
    end
  end
end
