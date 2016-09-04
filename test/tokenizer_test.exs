defmodule TokenizerTest do
  use ExUnit.Case
  doctest Xbitsy

  @moduletag timeout: 1000

  import Xbitsy.Tokenizer

  test "lex the letter B" do
    assert lex("BB") == ["BB"]
  end

  test "lex the BEGIN keyword" do
    assert lex("BEGIN") == ["BEGIN"]
  end

  test "lex the END keyword" do
    assert lex("END") == ["END"]
  end

  test "lex a space" do
    assert lex("  ") == ["  "]
  end

  test "lex a series of spaces" do
    assert lex("    ") == ["    "]
  end

  test "lex the bitsy null program" do
    assert lex("BEGIN END") == ["BEGIN", " ", "END"]
  end

  test "lex a variable name" do
    assert lex("BEGIN var END") == ["BEGIN", " ", "var", " ", "END"]
  end
end
