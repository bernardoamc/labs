defmodule Day20Test do
  use ExUnit.Case
  doctest Day20

  test "part1" do
    assert Day20.part1("^WNE$") == 3
    assert Day20.part1("^ENWWW(NEEE|SSE(EE|N))$") == 10
    assert Day20.part1("^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$") == 18
    assert Day20.part1("^ESSWWN(E|NNENN(EESS(WNSE|)SSS|WWWSSSSE(SW|NNNE)))$") == 23
    assert Day20.part1("^WSSEESWWWNW(S|NENNEEEENN(ESSSSW(NWSW|SSEN)|WSWWN(E|WWS(E|SS))))$") == 31
  end
end
