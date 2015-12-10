defmodule DealerTest do
  use ExUnit.Case
  doctest Dealer
  import Dealer

  test "compare returns a list of cards when ther's a war" do
    assert compare({ 'H3', 'C3' }) == { :war, [ 'H3', 'C3' ] }
  end
end
